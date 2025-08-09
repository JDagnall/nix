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
                            active = "";
                            default = "";
                            empty = "";
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
                        "format-wifi" = "{essid} 󰖩 ";
                        "format-ethernet" = "{ifname} 󰈀 ";
                        "format-disconnected" = " ";
                        "tooltip-format-disconnected" = "Disconnected";
                        "tooltip-format-wifi" = "{ipaddr}";
                        "tooltip-format-ethernet" = "{ipaddr}";
                    };
                    battery = {
                        states = {
                            good = 95;
                            warning = 30;
                            critical = 20;
                        };
                        format-time = "{H}:{M}";
                        format = "{capacity}% {icon}";
                        # format-charging = "{capacity}% 󰢝 ";
                        # format-plugged = "{capacity}% 󱟢 ";
                        format-icons = [
                            "󰁹"
                            "󰂂"
                            "󰂁"
                            "󰂀"
                            "󰁿"
                            "󰁾"
                            "󰁽"
                            "󰁼"
                            "󰁻"
                            "󰁺"
                        ];
                        tooltip-format = "{time}";
                    };
                    pulseaudio = {
                        format = "{volume}% {icon}";
                        format-bluetooth = "{volume}% {icon}";
                        format-muted = "󰖁 ";
                        format-icons = [
                            "󰖁 "
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
                        format = "{%I:%M %p}";
                        tooltip = false;
                    };
                    tray = {
                        icon-size = 14;
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
            systemd.enableInspect = false; # mouse over for CSS classes
        };
    };
}
