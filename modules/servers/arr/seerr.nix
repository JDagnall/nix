{self, ...}: {
    flake.modules.nixos.seerr = {config, ...}: let
        # arrCfg = config.my.servers.arr;
    in {
        imports = with self.modules.nixos; [servers arr];
        config = {
            my.servers.servers.seerr = {
                port = 5055;
                user = "seerr";
                group = null;
                mkRevProxy = true;
            };
            services.seerr = let
                serverCfg = config.my.servers.servers.seerr;
            in {
                enable = true;
                openFirewall = serverCfg.openFirewall;
                port = serverCfg.port;
                # configDir = ;
            };
        };
    };
}
