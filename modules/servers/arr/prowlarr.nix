{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.prowlarr = {config, ...}: let
        # cfg = config.servers.arr.prowlarr
    in {
        imports = with self.modules.nixos; [servers arr];
        config = {
            warnings = lib.optional config.networking.enableIPv6 "Prowlarr may not work with captcha solvers if ipv6 is enabled.";
            my.servers.servers.prowlarr = {
                port = 9696;
                user = null;
                group = null;
                reverseProxy = {
                    enable = true;
                };
                dns.enable = true;
                dashboardIcon = {
                    enable = true;
                    icon = builtins.fetchurl {
                        url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/prowlarr.svg";
                        sha256 = "14pqf1crgw23j4hdqah1gwngad4wlni4cc8wyv40dlblqq78q1lg";
                        name = "prowlarr.svg";
                    };
                };
            };
            services.prowlarr = let
                serverCfg = config.my.servers.servers.prowlarr;
            in {
                enable = true;
                openFirewall = serverCfg.openFirewall;
                # dataDir = ;
                # environmentFiles = []; #sops
                settings = {
                    log.analyticsEnabled = false;
                    server = {
                        port = serverCfg.port;
                        bindaddress = serverCfg.host;
                        # would be 'prowlarr', if intended to access through reverse proxy,
                        # in format domain-name.com/prowlarr
                        # urlbase = ;
                    };
                    update.automatically = false;
                };
            };
        };
    };
}
