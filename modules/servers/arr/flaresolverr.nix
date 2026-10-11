{self, ...}: {
    flake.modules.nixos.flaresolverr = {config, ...}: {
        imports = with self.modules.nixos; [servers arr];
        config = {
            my.servers.servers.flaresolverr = {
                port = 8191;
                user = null;
                group = null;
                mkRevProxy = true;
            };
            services.flaresolverr = let
                serverCfg = config.my.servers.servers.flaresolverr;
            in {
                enable = true;
                openFirewall = serverCfg.openFirewall;
                port = serverCfg.port;
            };
        };
    };
}
