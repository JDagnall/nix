{ lib, config, ... }:
let
    inherit (lib)
        mkIf
        mkEnableOption
        mkOrder
        mkMerge
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
            settings =
                let
                    inherit (config.ui) swayosd;
                    inherit (config) pipewire;
                    inherit (config.tools)
                        brightnessctl
                        playerctl
                        ;
                in
                {
                    bindel =
                        [ ]
                        ++ (
                            if (swayosd.enable && brightnessctl.enable) then
                                [
                                    ",XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
                                    ",XF86MonBrightnessUp, exec, swayosd-client --brightness raise"
                                ]
                            else
                                [ ]
                        )
                        ++ (
                            if (brightnessctl.enable && !swayosd.enable) then
                                [
                                    ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
                                    ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
                                ]
                            else
                                [ ]
                        )
                        ++ (
                            if (swayosd.enable && pipewire.enabled) then
                                [
                                    ",XF86AudioRaiseVolume, exec swayosd-client --output-volume raise"
                                    ",XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
                                    ",XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
                                    ",XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
                                ]
                            else
                                [ ]
                        )
                        ++ (
                            if (pipewire.enabled && !swayosd.enable) then
                                [
                                    ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
                                    ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
                                    ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
                                    ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
                                ]
                            else
                                [ ]
                        );

                    bindl =
                        [ ]
                        ++ (
                            if playerctl.enable then
                                [
                                    ",XF86AudioNext, exec, playerctl next"
                                    ",XF86AudioPause, exec, playerctl play-pause"
                                    ",XF86AudioPlay, exec, playerctl play-pause"
                                    ",XF86AudioPrev, exec, playerctl previous"
                                ]
                            else
                                [ ]
                        );
                };
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
