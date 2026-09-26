{
    lib,
    config,
    ...
}: let
    cfg = config.service.media-services;
in {
    options = {
        service.media-services.jackett = {
            enable = lib.mkEnableOption "Enable jackett, an indexer manager.";
        };
    };
    config = {
        service.media-services.services.jackett = {
            port = 9117;
            user = "jackett";
            inMediaGroup = true;
            mkRevProxy = true;
        };
        services.jackett = let
            serviceCfg = config.service.media-services.services.jackett;
        in
            lib.mkIf cfg.jackett.enable {
                enable = true;
                openFirewall = false; # tailscale
                # dataDir = ;
                user = serviceCfg.user;
                group = lib.mkIf serviceCfg.inMediaGroup cfg.group.name;
                port = serviceCfg.port;
            };
    };
}
