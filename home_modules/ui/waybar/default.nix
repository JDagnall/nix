{ lib, config, ... }:
let
    inherit (lib)
        mkIf
        mkEnableOption
        mkOption
        types
        ;
in
{
    options = {
        ui.waybar.enable = mkEnableOption {
            default = false;
            description = "Enable waybar config";
        };
        ui.waybar.autostart = mkOption {
            type = types.bool;
            default = config.ui.waybar.enable;
            description = ''
                Enable autostart for waybar. Configured in 
                whichever enabled config should be responsible for autostarts.'';
        };
    };
    config = mkIf config.ui.waybar.enable {
        programs.waybar = {
            enable = true;
            settings = [
                {
                    modules-left = [ "hyprland/workspaces" ];
                    modules-center = [ "clock" ];
                    modules-right = [
                        "tray"
                        "battery"
                        "network"
                        "pulseaudio"
                    ];

                    "hyprland/workspaces" = {
                        format = "{icon}";
                        format-icons = {
                            active = "";
                            default = "";
                            empty = "";
                        };
                        persistent-workspaces = {
                            "*" = [
                                1
                                2
                                3
                                4
                                5
                            ];
                        };
                    };
                    network = {
                        format-wifi = "{essid} 󰖩 ";
                        format-ethernet = "{ifname} 󰈀 ";
                        format-disconnected = " ";
                        tooltip-format-disconnected = "Disconnected";
                        tooltip-format-wifi = "{ipaddr}";
                        tooltip-format-ethernet = "{ipaddr}";
                    };
                    battery = {
                        states = {
                            good = 95;
                            warning = 30;
                            critical = 20;
                        };
                        interval = 15;
                        format-time = "{H}:{M}";
                        format = "{capacity}% {icon}";
                        min-length = 5;
                        justify = "center";
                        format-charging = "{capacity}% 󰢝 ";
                        # format-plugged = "{capacity}% 󱟢 ";
                        format-icons = [
                            "󰁺"
                            "󰁻"
                            "󰁼"
                            "󰁽"
                            "󰁾"
                            "󰁿"
                            "󰂀"
                            "󰂁"
                            "󰂂"
                            "󰁹"
                        ];
                        tooltip-format = "{time}";
                    };
                    pulseaudio = {
                        format = "{volume}% {icon}";
                        format-bluetooth = "{volume}% {icon}";
                        min-length = 5;
                        justify = "center";
                        format-muted = "󰖁 ";
                        format-icons = [
                            "󰕿 "
                            "󰖀 "
                            "󰕾 "
                        ];
                        tooltip = false;
                        states = {
                            high = 85;
                            medium = 50;
                            low = 1;
                            off = 0;
                        };
                    };
                    clock = {
                        format = " {:%I:%M %p %a %b %d}";
                        tooltip = false;
                    };
                    tray = {
                        icon-size = 17;
                        spacing = 10;
                        tooltip = false;
                    };

                    expand-center = false;
                    expand-left = false;
                    expand-right = false;
                    layer = "bottom";
                    output = null; # for multiple monitors
                    position = "top";
                    width = null;
                    height = null;
                    no-center = false;
                    spacing = 5;
                    mode = "dock";
                    start_hidden = false;
                    reload_style_on_change = true;
                    fixed_center = true;
                }
            ];
            style = builtins.readFile ./style.css;
            ## DEBUG
            systemd.enableDebug = false; # debug logging
            systemd.enableInspect = true; # mouse over for CSS classes
        };
        # stylix theming
        stylix.targets.waybar = {
            enable = true; # just adds colors and font config
            addCss = false;
            enableCenterBackColors = true;
            enableRightBackColors = true;
            enableLeftBackColors = true;
            font = "serif";
        };
    };
}
