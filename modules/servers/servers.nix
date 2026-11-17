# Servers in this repo are supposed to be services that are intended to be
# `forwarded`, meaning externally accessible whether just on the local network
# or otherwise. And thus each `server` defines its port and access and how it
# wants be forwared (rev proxy, subdomain, etc)
{
    # self,
    lib,
    ...
}: {
    flake.modules.nixos.servers = {config, ...}: let
        cfg = config.my.servers;
    in {
        key = "my/nixos/servers";
        # import = with self.modules.nixos; [];
        options.my = {
            servers = {
                publicHostNames = lib.mkOption {
                    type = with lib.types; listOf str;
                    description = ''
                        The public hostnames that identify this device.
                        Some servers will need this for security purposes.
                    '';
                    default = [];
                };
                servers = lib.mkOption {
                    type = lib.types.attrsOf (lib.types.submodule ({
                        name,
                        config,
                        ...
                    }: {
                        freeformType = lib.types.attrsOf lib.types.anything;
                        options = {
                            name = lib.mkOption {
                                type = lib.types.str;
                                default = name;
                            };
                            host = lib.mkOption {
                                type = lib.types.str;
                                default = "localhost";
                                description = "Listen address.";
                            };
                            # should maybe be a list?
                            port = lib.mkOption {
                                type = lib.types.port;
                                description = "Port that the server runs on";
                            };
                            user = lib.mkOption {
                                type = lib.types.nullOr lib.types.str;
                                description = "The user that this server runs under.";
                            };
                            group = lib.mkOption {
                                type = lib.types.nullOr lib.types.str;
                                description = "The group that this server runs under.";
                            };
                            openFirewall = lib.mkOption {
                                type = lib.types.bool;
                                description = "Whether to open this servers port.";
                                default = false;
                            };
                            reverseProxy = {
                                enable = lib.mkEnableOption "Reverse proxy this server.";
                                port = lib.mkOption {
                                    type = lib.types.port;
                                    description = "Port to reverse proxy to.";
                                    default = config.port;
                                };
                                useSSL = lib.mkEnableOption ''
                                    Whether to use SSL for communication internally between
                                    the client and the proxy.
                                '';
                                SSLCert = lib.mkOption {
                                    type = with lib.types; nullOr path;
                                    default = null;
                                    description = "The SSL cert to trust for this server.";
                                };
                            };
                            dns = {
                                enable = lib.mkEnableOption "Whether to list DNS subdomain entries pointing at this device for the server.";
                                subdomain = lib.mkOption {
                                    type = lib.types.str;
                                    description = "The subdomain to assign";
                                    default = name;
                                };
                                domains = lib.mkOption {
                                    type = with lib.types; listOf str;
                                    default = map (hostname: "${config.dns.subdomain}.${hostname}") cfg.publicHostNames;
                                    description = "The virtual hostnames to reverse proxy.";
                                };
                            };
                            dashboardIcon = {
                                enable = lib.mkEnableOption "Make a dashboard icon / link for the server if one exists.";
                                icon = lib.mkOption {
                                    # could allow urls here but I can't really think when that would be necesary
                                    type = with lib.types; nullOr path;
                                    default = null;
                                    description = ''
                                        The Icon for the server, should probably be grabbed with fetchUrl.
                                    '';
                                };
                            };
                            auth = {
                                forwardAuth =
                                    (lib.mkEnableOption ''
                                        Whether to put this server behind an authentication layer if one exists using
                                        the reverse proxy or some other means. This may be turned off if the service
                                        already has an authentication protocol that is trusted, if the service does
                                        not require authentication or if the service uses the authentication service
                                        service as a OIDC privoder internally.
                                    '')
                                    // {default = true;};
                                accessLevel = lib.mkOption {
                                    type = with lib.types; nullOr str;
                                    description = ''
                                        A string describing the access level / group / realm required for
                                        access to the service. The auth provider / logic in the configuration
                                        can decide what `null` means, presumably no access or 'admin' access.
                                    '';
                                };
                            };
                            # there should be an access option here that defines along with some
                            # identity provider and an `accounts` module, who can access a service
                        };
                    }));
                };
            };
        };
        config = {
            assertions = lib.concatLists [
                (lib.mapAttrsToList (name: server: {
                    assertion = server.reverseProxy.useSSL -> server.reverseProxy.SSLCert != null;
                    message = "If SSL is enabled for the reverse proxy, a SSL cert must be specified, for server ${server.name}.";
                })
                cfg.servers)
            ];
        };
    };
}
