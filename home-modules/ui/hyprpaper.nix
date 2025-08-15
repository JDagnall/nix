{ lib, config, ... }:
let
    inherit (lib) mkIf mkEnableOption;
in
{
    options = {
        ui.hyprpaper.enable = mkEnableOption {
            description = "Enable hyprpaper config";
        };
    };
    config = mkIf config.ui.hyprpaper.enable {
        assertions = [
            {
                assertion = config.window-manager.hyprland.enable;
                message = ''
                    hyprpaper cannot work without hyprland enabled.
                    Please enable hyprland or disable hyprpaper'';
            }
        ];
        services.hyprpaper = {
            enable = true;
            settings = {
                splash = false; # text
                splash_offset = 1.0;
                ipc = true; # allows hyprpaper to be controlled by hyprland
            };
        };
        stylix.targets.hyprpaper.enable = config.stylix.enableHomeConfig;
    };
}
