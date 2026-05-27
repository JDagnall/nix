{
    pkgs,
    lib,
    config,
    ...
}: {
    options = {
        ui.syncthingtray.enable = lib.mkEnableOption {
            description = ''
                Enable syncthingtray config. Just a gui helper for syncthing,
                the actual syncthing config is not in home-manager'';
        };
        ui.syncthingtray.autostart = lib.mkOption {
            type = lib.types.bool;
            default = config.ui.syncthingtray.enable;
            description = ''
                Enable autostart for syncthingtray. Configured in 
                whichever enabled config should be responsible for autostarts.'';
        };
    };
    config = lib.mkIf config.ui.syncthingtray.enable {
        home.packages = [pkgs.syncthingtray];
    };
}
