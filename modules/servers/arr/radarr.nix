{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.radarr = {config, ...}: let
        arrCfg = config.my.servers.arr;
        # cfg = config.my.servers.radarr;
    in {
        imports = with self.modules.nixos; [servers arr];
        config = {
            my.servers.servers.radarr = {
                port = 7878;
                user = "radarr";
                group = arrCfg.group.name;
                reverseProxy = {
                    enable = true;
                };
                dns.enable = true;
                dashboardIcon = {
                    enable = true;
                    icon = builtins.fetchurl {
                        url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/radarr.svg";
                        sha256 = "07y1phs8b01qsrppl947c8hh6sc03jag3004x65fl1s9ydwgm0n5";
                        name = "radarr.svg";
                    };
                };
            };
            services.radarr = let
                serverCfg = config.my.servers.servers.radarr;
            in {
                enable = true;
                openFirewall = serverCfg.openFirewall;
                # dataDir = ;
                user = serverCfg.user;
                group = serverCfg.group;
                # environmentFiles = []; #sops
                settings = {
                    log.analyticsEnabled = false;
                    server = {
                        port = serverCfg.port;
                        bindaddress = serverCfg.host;
                        # would be 'radarr', if intended to access through reverse proxy,
                        # in format domain-name.com/prowlarr
                        # urlbase = ;
                    };
                    update.automatically = false;
                };
            };
            systemd.services.radarr.serviceConfig.UMask = lib.mkForce arrCfg.umask;
        };
    };
}
