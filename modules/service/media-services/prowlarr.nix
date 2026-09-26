{
    lib,
    config,
    ...
}: let
    cfg = config.service.media-services;
in {
    options = {
        service.media-services.prowlarr = {
            enable = lib.mkEnableOption "Enable Prowlarr.";
        };
    };
    config = lib.mkIf (cfg.enable && cfg.prowlarr.enable) {
        warnings = lib.optional config.networking.enableIPv6 "Prowlarr may not work with captcha solvers if ipv6 is enabled.";
        service.media-services.services.prowlarr = {
            port = 9696;
            user = "prowlarr";
            inMediaGroup = false;
            mkRevProxy = true;
        };
        services.prowlarr = let
            serviceCfg = config.service.media-services.services.prowlarr;
        in {
            enable = true;
            openFirewall = false; # tailscale;
            # dataDir = ;
            # environmentFiles = []; #sops
            settings = {
                log.analyticsEnabled = false;
                server = {
                    port = serviceCfg.port;
                    bindaddress = "localhost";
                    # would be 'prowlarr', if intended to access through reverse proxy,
                    # in format domain-name.com/prowlarr
                    # urlbase = ;
                };
                update.automatically = false;
            };
        };
    };
}
