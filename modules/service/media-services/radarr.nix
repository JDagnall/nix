{
    lib,
    config,
    ...
}: let
    cfg = config.service.media-services;
in {
    options = {
        service.media-services.radarr.enable = lib.mkEnableOption "Enable Radarr.";
    };
    config = lib.mkIf (cfg.enable && cfg.radarr.enable) {
        service.media-services.services.radarr = {
            port = 7878;
            user = "radarr";
            inMediaGroup = true;
            mkRevProxy = true;
        };
        services.radarr = let
            serviceCfg = config.service.media-services.services.radarr;
        in {
            enable = true;
            openFirewall = false; # tailscale / caddy
            # dataDir = ;
            user = serviceCfg.user;
            group = lib.mkIf serviceCfg.inMediaGroup cfg.group.name;
            # environmentFiles = []; #sops
            settings = {
                log.analyticsEnabled = false;
                server = {
                    port = serviceCfg.port;
                    bindaddress = "localhost";
                    # would be 'radarr', if intended to access through reverse proxy,
                    # in format domain-name.com/prowlarr
                    # urlbase = ;
                };
                update.automatically = false;
            };
        };
        systemd.services.radarr.serviceConfig.Umask = "0007";
    };
}
