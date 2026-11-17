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
                reverseProxy = {
                    enable = true;
                };
                dns.enable = true;
                dashboardIcon = {
                    enable = true;
                    icon = builtins.fetchurl {
                        url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/seerr.svg";
                        sha256 = "1im1jiscrczgm49yclcgrf2rdxifzj2rplknfc4rrx51r73h7xqx";
                        name = "seerr.svg";
                    };
                };
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
