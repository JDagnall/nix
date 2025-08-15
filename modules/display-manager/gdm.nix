{ lib, config, ... }:
{
    options = {
        display-manager.gdm.enable = lib.mkEnableOption {
            default = "Enable GDM display manager config.";
        };
    };
    config = lib.mkIf config.display-manager.gdm.enable {
        services.displayManager.gdm = {
            enable = true;
            wayland = config.window-manager.hyprland.enable; # could add an or constraint here for future WM's
            debug = false;
            banner = "Hello There!"; # just greeting text
            autoSuspend = true;
        };
        stylix.targets.gnome.enable = config.stylix.enableConfig;
    };
}
