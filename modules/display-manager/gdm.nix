{
    lib,
    config,
    ...
}: {
    options = {
        display-manager.gdm.enable = lib.mkEnableOption {
            default = "Enable GDM display manager config.";
        };
    };
    config = lib.mkIf config.display-manager.gdm.enable {
        services.displayManager.gdm = {
            enable = true;
            debug = false;
            banner = "Hello There!"; # just greeting text
            autoSuspend = true;
        };
        stylix.targets.gnome.enable = config.stylix.enableConfig;
    };
}
