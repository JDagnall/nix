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
        service.media-services.services.flaresolverr = {
            port = 8191;
            user = "flaresolverr";
            inMediaGroup = false;
            mkRevProxy = true;
        };
        services.flaresolverr = let
            serviceCfg = config.service.media-services.services.flaresolverr;
        in
            lib.mkIf cfg.flaresolverr.enable {
                enable = true;
                openFirewall = false;
                port = serviceCfg.port;
            };
    };
}
