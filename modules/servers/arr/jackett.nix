{self, ...}: {
    flake.modules.nixos.jackett = {config, ...}: let
        # arrCfg = config.my.servers.arr;
    in {
        imports = with self.modules.nixos; [servers arr];
        config = {
            my.servers.servers.jackett = {
                port = 9117;
                user = "jackett";
                group = "jackett";
                mkRevProxy = true;
            };
            services.jackett = let
                serverCfg = config.my.servers.servers.jackett;
            in {
                enable = true;
                # dataDir = ;
                openFirewall = serverCfg.openFirewall;
                user = serverCfg.user;
                group = serverCfg.group;
                port = serverCfg.port;
            };
        };
    };
}
