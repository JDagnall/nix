{
    # self,
    lib,
    ...
}: {
    flake.modules.nixos.dns = {config, ...}: let
        cfg = config.my.services.dns;
    in {
        key = "my/nixos/dns";
        # imports = with self.modules.nixos; [];
        options = {
            my.services.dns = {
                type = lib.mkOption {
                    type = lib.types.enum ["coredns" "dnsmasq" "resolved"];
                    description = "The dns service being used";
                };
                entries = lib.mkOption {
                    type = with lib.types;
                        listOf (submodule {
                            options = {
                                ip = lib.mkOption {type = str;};
                                domain = lib.mkOption {type = str;};
                                wildcard = lib.mkEnableOption ''
                                    Whether the domain contains a wildcard.
                                    Not all DNS servers support wildcards.
                                '';
                            };
                        });
                    default = [];
                    description = "DNS entries";
                };
                loopbackListenAddress = lib.mkOption {
                    type = lib.types.str;
                    default =
                        if config.services.resolved.enable && (cfg.type != "resolved")
                        then "127.0.0.35"
                        else "127.0.0.1";
                    description = ''
                        The listen address for the dnsmasq service locally. In
                        the case that systemd-resolved is enabled but not the the
                        main DNS service, the service needs to be moved off of the
                        default listening address and systemd-resolved will then
                        forward DNS traffic to the service. If the DNS service is
                        forwarded as a server and port 53 is open, incoming traffic
                        will go straight to the main service not via systemd-resolved
                        unless of course it is the main service.
                    '';
                };
            };
        };
        # config = {};
    };
}
