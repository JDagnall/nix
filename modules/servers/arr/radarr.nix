{self, ...}: {
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
                inMediaGroup = true;
                mkRevProxy = true;
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
            # TODO: use the arr option umask here?
            systemd.services.radarr.serviceConfig.Umask = "0007";
        };
    };
}
