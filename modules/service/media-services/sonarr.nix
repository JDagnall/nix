{
    lib,
    config,
    ...
}: let
    cfg = config.service.media-services;
in {
    options = {
        service.media-services.sonarr.enable = lib.mkEnableOption "Enable Sonarr.";
    };
    config = lib.mkIf (cfg.enable && cfg.sonarr.enable) {
        service.media-services.services.sonarr = {
            port = 8989;
            user = "sonarr";
            inMediaGroup = true;
            mkRevProxy = true;
        };
        services.sonarr = let
            serviceCfg = config.service.media-services.services.sonarr;
        in {
            enable = true;
            openFirewall = false; # tailscale;
            # dataDir = ;
            user = serviceCfg.user;
            group = lib.mkIf serviceCfg.inMediaGroup cfg.group.name;
            # environmentFiles = []; #sops
            settings = {
                log.analyticsEnabled = false;
                server = {
                    port = serviceCfg.port;
                    bindaddress = "localhost";
                    # would be 'sonarr', if intended to access through reverse proxy,
                    # in format domain-name.com/prowlarr
                    # urlbase = ;
                };
                update.automatically = false;
            };
        };
        systemd.services.sonarr.serviceConfig.Umask = "0007";
    };
}
