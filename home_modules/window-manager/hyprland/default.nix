{ lib, config, ... }:
let
    inherit (lib)
        mkIf
        mkEnableOption
        mkOrder
        mkMerge
        optionals
        ;
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
                enable = true; # important env variables for hyprland session
                # extraCommands = [];
                # enableXdgAutostart = true;
                # variables = [];
            };
            # importantPrefixes = [];
            # portalPackage = ;
            xwayland.enable = true;
            # plugins = [ ];
            extraConfig =
                let
                    configFile = builtins.readFile ./hyprland.conf;
                    autostarts = ''
                        #################
                        ### AUTOSTART ###
                        #################
                        ${if config.ui.waybar.autostart then "exec-once = waybar &" else ""}
                        ${if config.ui.syncthingtray.autostart then "exec-once = syncthingtray &" else ""}
                        ${if config.tools.keepassxc.autostart then "exec-once = keepassxc --minimized &" else ""}
                    '';
                    orderedConfigFile = mkOrder 500 configFile;
                    orderedAutostarts = mkOrder 1000 autostarts;
                    merged = mkMerge [
                        orderedConfigFile
                        orderedAutostarts
                    ];
                in
                merged;
        };
        stylix.targets.hyprland = {
            enable = true;
            hyprpaper.enable = config.ui.hyprpaper.enable;
        };
    };
}
