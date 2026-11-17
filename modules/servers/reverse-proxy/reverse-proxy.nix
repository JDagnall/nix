{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.reverseProxy = {config, ...}: {
        key = "my/nixos/servers/proxy";
        imports = with self.modules.nixos; [servers];
        options = {
            my.servers = {
                reverseProxy = {
                    type = lib.mkOption {
                        type = lib.types.enum ["caddy"];
                        description = "The type of reverse proxy.";
                    };
                    group = lib.mkOption {
                        type = lib.types.str;
                        default = "rproxy";
                        description = ''
                            The group all reverse proxies should be in, for giving
                            access to certificates, etc.
                        '';
                    };
                };
            };
        };
        config = let
            cfg = config.my.servers.reverseProxy;
        in {
            users.groups."${cfg.group}" = {};
        };
    };
}
