{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.sonarr = {config, ...}: let
        arrCfg = config.my.servers.arr;
    in {
        imports = with self.modules.nixos; [servers arr];
        config = {
            my.servers.servers.sonarr = {
                port = 8989;
                user = "sonarr";
                group = arrCfg.group.name;
                reverseProxy = {
                    enable = true;
                };
                dns.enable = true;
                dashboardIcon = {
                    enable = true;
                    icon = builtins.fetchurl {
                        url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/sonarr.svg";
                        sha256 = "12z4pagazvx5mv80wwby79pgbqnl13p19x8w66s1k5x4vrq80xp2";
                        name = "sonarr.svg";
                    };
                };
            };
            services.sonarr = let
                serverCfg = config.my.servers.servers.sonarr;
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
                        # would be 'sonarr', if intended to access through reverse proxy,
                        # in format domain-name.com/prowlarr
                        # urlbase = ;
                    };
                    update.automatically = false;
                };
            };
            systemd.services.sonarr.serviceConfig.UMask = lib.mkForce arrCfg.umask;
        };
    };
}
