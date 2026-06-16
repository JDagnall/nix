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
        services.seerr = {
            enable = true;
            openFirewall = true; # tailscale / caddy
            port = 5055;
            # configDir = ;
        };
    };
}
