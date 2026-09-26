{
    lib,
    config,
    ...
}: let
    cfg = config.service.media-services;
in {
    options = {
        service.media-services.seerr.enable = lib.mkEnableOption "Enable seerr.";
    };
    config = lib.mkIf (cfg.enable && cfg.seerr.enable) {
        service.media-services.services.seerr = {
            port = 5055;
            user = "seerr";
            inMediaGroup = false;
            mkRevProxy = true;
        };
        services.seerr = let
            serviceCfg = config.service.media-services.services.seerr;
        in {
            enable = true;
            openFirewall = false; # tailscale / caddy
            port = serviceCfg.port;
            # configDir = ;
        };
    };
}
