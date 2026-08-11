{
    lib,
    config,
    ...
}: let
    cfg = config.service.media-services;
in {
    options = {
        service.media-services = {
            flaresolverr.enable = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Enable flaresolverr, solves captchas.";
            };
        };
    };
    config = lib.mkIf cfg.enable {
        services.flaresolverr = lib.mkIf cfg.flaresolverr.enable {
            enable = true;
            openFirewall = false;
            port = 8191;
        };
    };
}
