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
                        # if I am going to use this it should be forwarded over caddy, but
                        # I have not refactored the wat services are done yet. When I have this will
                        # go along with that. And the host will be set to localhost.
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
