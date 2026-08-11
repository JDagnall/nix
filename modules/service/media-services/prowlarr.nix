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
    config = lib.mkIf cfg.enable {
        warnings = lib.optional config.networking.enableIPv6 "Prowlarr may not work with captcha solvers if ipv6 is enabled.";
        services.prowlarr = lib.mkIf cfg.prowlarr.enable {
            enable = true;
            openFirewall = false; # tailscale;
            # dataDir = ;
            # environmentFiles = []; #sops
            settings = {
                log.analyticsEnabled = false;
                server = {
                    port = 9696;
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
