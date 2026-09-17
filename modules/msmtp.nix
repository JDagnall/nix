# Replaces the `sendmail` program so mail being sent locally can be sent through
# a remote SMTP server like gmail.
# So works as serverless mail relay
{
    lib,
    config,
    ...
}: let
    cfg = config.msmtp;
in {
    options.msmtp = {
        enable = lib.mkEnableOption "Enable msmtp, a simple mail relay.";
        accounts = lib.mkOption {
            default = {};
            description = "Accounts to relay mail to.";
            type = with lib.types;
                attrsOf (submodule {
                    options = {
                        host = lib.mkOption {
                            description = "The address of the service";
                            type = str;
                        };
                        user = lib.mkOption {
                            type = str;
                            description = "Username for the account";
                        };
                        from = lib.mkOption {
                            type = str;
                            description = "The full email address the email will be addressed from.";
                        };
                        auth = lib.mkOption {
                            type = bool;
                            description = "Do auth for the account";
                            default = false;
                        };
                        extraConfig = lib.mkOption {
                            type = attrs;
                            description = "Extra config for the account. Will override defaults.";
                            default = {};
                        };
                    };
                });
        };
        defaultAccount = lib.mkOption {
            description = "The attr name of the account to be used as the default.";
            type = with lib.types; nullOr str;
            default = null;
        };
        defaultAlias = lib.mkOption {
            description = "The forwarding address for all local email addresses, not aliased.";
            default = null;
            type = with lib.types;
                nullOr
                (submodule ({name, ...}: {
                    options = {
                        name = lib.mkOption {
                            type = str;
                            default = name;
                        };
                        to = lib.mkOption {
                            type = str;
                            description = "The email address being aliased to.";
                        };
                    };
                }));
        };
        aliases = lib.mkOption {
            default = {};
            description = ''
                Aliases of email addresses. For example you might alias the local
                address `root` to a real email address.
            '';
            type = with lib.types;
                attrsOf (submodule ({name, ...}: {
                    options = {
                        name = lib.mkOption {
                            type = str;
                            default = name;
                        };
                        from = lib.mkOption {
                            type = str;
                            description = "The email address being aliased.";
                        };
                        to = lib.mkOption {
                            type = listOf str;
                            description = "The email addresses being aliased to.";
                        };
                    };
                }));
        };
    };
    config = lib.mkIf cfg.enable {
        users.groups."msmtp" = {};
        # add users /services to the 'msmtp' group to give them access
        sops.secrets = let
            host = config.networking.hostName;
        in
            lib.mkIf config.sops.enable
            (
                lib.genAttrs'
                (map (x: x.name) (builtins.filter (x: x.value.auth) (lib.attrsToList cfg.accounts)))
                (name: {
                    name = "msmtp/accounts/${name}";
                    value = {
                        sopsFile = ../secrets/${host}/msmtp.yaml;
                        group = config.users.groups."msmtp".name;
                        mode = "0440";
                    };
                })
            );

        environment.etc."aliases".text = let
            mkAlias = alias: "${alias.from}: ${lib.concatStringsSep ", " alias.to}";
            mkDefaultAlias = alias: "default: ${alias.to}";
        in ''
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: alias: mkAlias alias) cfg.aliases)}
            ${lib.optionalString (cfg.defaultAlias != null) (mkDefaultAlias cfg.defaultAlias)}

        '';
        programs.msmtp = {
            enable = true;
            setSendmail = true;
            defaults = {
                aliases = "/etc/aliases";
                port = 465;
                tls = true;
                tls_starttls = "off";
            };
            accounts = lib.mapAttrs' (
                name: acc: (
                    lib.nameValuePair
                    (
                        if name == cfg.defaultAccount
                        then "default"
                        else name
                    )
                    (
                        (lib.removeAttrs acc ["extraConfig"])
                        // lib.optionalAttrs acc.auth
                        {
                            passwordeval = "cat ${config.sops.secrets."msmtp/accounts/${name}".path}";
                        }
                        // acc.extraConfig
                    )
                )
            )
            cfg.accounts;
        };
    };
}
