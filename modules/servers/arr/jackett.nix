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
                reverseProxy = {
                    enable = true;
                };
                dns.enable = true;
                dashboardIcon = {
                    enable = true;
                    icon = builtins.fetchurl {
                        url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/jackett.svg";
                        sha256 = "05v0fm08xpp6zkkwpcxxb0ziml8wqvhz2azq80914f94g0n7j4fj";
                        name = "jackett.svg";
                    };
                };
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
