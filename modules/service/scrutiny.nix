{
    lib,
    config,
    ...
}: let
    cfg = config.service.scrutiny;
in {
    options = {
        service.scrutiny = {
            enable = lib.mkEnableOption "Enable scrutiny a web UI drive monitoring service.";
        };
    };
    config = lib.mkIf cfg.enable {
        services.scrutiny = {
            enable = true;
            # kinda pointless to use this without this. This will turn on services.smartd
            collector.enable = true;
            openFirewall = true; # temp
            settings = {
                web = {
                    # if I am going to use this it should be forwarded over caddy, but
                    # I have not refactored the wat services are done yet. When I have this will
                    # go along with that. And the host will be set to localhost.
                    listen = {
                        host = "0.0.0.0";
                        port = 9111;
                        # basepath = "/"
                    };
                };
            };
        };
    };
}
