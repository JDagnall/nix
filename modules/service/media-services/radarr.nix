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
    config = lib.mkIf (cfg.enable && cfg.sonarr.enable) {
        services.radarr = {
            enable = true;
            openFirewall = false; # tailscale;
            # dataDir = ;
            # user = ;
            group = cfg.group.name;
            # environmentFiles = []; #sops
            settings = {
                log.analyticsEnabled = false;
                server = {
                    port = 7878;
                    bindaddress = "localhost";
                    # would be 'radarr', if intended to access through reverse proxy,
                    # in format domain-name.com/prowlarr
                    # urlbase = ;
                };
                update.automatically = false;
            };
        };
    };
}
