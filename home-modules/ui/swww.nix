{
    lib,
    config,
    ...
}: {
    options = {
        ui.swww.enable = lib.mkEnableOption {
            default = false;
            description = "Enable swww";
        };
    };
    config = lib.mkIf config.ui.swww.enable {
        services.swww.enable = true;
        # config for adding autostart to hyprland or whichever and selecting a wallpaper would go here
    };
}
