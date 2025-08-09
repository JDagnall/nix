{ lib, config, ... }:
let
    inherit (lib) mkIf mkEnableOption;
in
{
    options = {
        ui.waybar.enable = mkEnableOption {
            default = false;
            description = "Enable waybar config";
        };
    };
    config = mkIf config.ui.waybar.enable {
        programs.waybar =
            let
                settingsJSONstring = builtins.readFile ./config.jsonc;
                settingsJSON = builtins.fromJSON settingsJSONstring;
            in
            {
                enable = true;
                settings = [
                    settingsJSON
                ];
                style = builtins.readFile ./style.css;
                ## DEBUG
                systemd.enableDebug = false; # debug logging
                systemd.enableInspect = false; # mouse over for CSS classes
            };
    };
}
