{self, ...}: {
    flake.modules.nixos.flaresolverr = {config, ...}: {
        imports = with self.modules.nixos; [servers arr];
        config = {
            my.servers.servers.flaresolverr = {
                port = 8191;
                user = null;
                group = null;
                reverseProxy = {
                    enable = true;
                };
                dns.enable = true;
                dashboardIcon = {
                    enable = true;
                    icon = builtins.fetchurl {
                        url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/flaresolverr.svg";
                        sha256 = "18dwvs8z3l7jiga49n8vim0sw14lx2isaqdinyfsn9p8fscl2kfb";
                        name = "flaresolverr.svg";
                    };
                };
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
