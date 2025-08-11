{ lib, config, ... }:
let
    inherit (lib) mkIf mkEnableOption;
in
{
    options = {
        window-manager.hyprland.enable = mkEnableOption {
            default = false;
            description = "Enable Hyprland config";
        };
    };
    config = mkIf config.window-manager.hyprland.enable {
        wayland.windowManager.hyprland = {
            enable = true;
            # settings = { };
            systemd = {
                enable = true;
                # extraCommands = [];
                # enableXdgAutostart = true;
                # variables = [];
            };
            # importantPrefixes = [];
            # portalPackage = ;
            xwayland.enable = true;
            # plugins = [ ];
            extraConfig = builtins.readFile ./hyprland.conf;
        };
        stylix.targets.hyprland = {
            enable = true;
        };
    };
}
