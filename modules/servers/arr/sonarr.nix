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
                mkRevProxy = true;
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
