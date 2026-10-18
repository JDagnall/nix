{self, ...}: {
    flake.modules.nixos.scrutiny = {config, ...}: let
        # cfg = config.servers.scrutiny;
    in {
        imports = with self.modules.nixos; [servers];
        config = let
            serverCfg = config.my.servers.servers.scrutiny;
        in {
            my.servers.servers.scrutiny = {
                port = 9111;
                user = null;
                group = null;
                mkRevProxy = true;
            };
            services.scrutiny = {
                enable = true;
                # kinda pointless to use this without this. This will turn on services.smartd
                collector.enable = true;
                openFirewall = serverCfg.openFirewall;
                settings = {
                    web = {
                        listen = {
                            host = serverCfg.host;
                            port = serverCfg.port;
                            # basepath = "/"
                        };
                    };
                };
            };
        };
    };
}
