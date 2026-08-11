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
        services.jackett = lib.mkIf cfg.jackett.enable {
            enable = true;
            openFirewall = false; # tailscale
            # dataDir = ;
            # user= "jackett";
            group = cfg.group.name;
            # port = 9117;
        };
    };
}
