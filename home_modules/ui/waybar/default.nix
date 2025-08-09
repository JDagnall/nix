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
                        "format-wifi" = " ";
                        "format-ethernet" = " ";
                        "format-disconnected" = " ";
                        "tooltip-format-disconnected" = "Disconnected";
                        "tooltip-format-wifi" = "{essid} ({signalStrength}%)  ";
                        "tooltip-format-ethernet" = "{ifname}  ";
                    };
                    battery = { };
                    pipewire = { };
                    clock = {
                        format = "{:%I:%M:%S: %p} ";
                        tooltip-format = "<tt>{calendar}</tt>";
                    };
                    tray = {
                        icon-size = 14;
                        spacing = 10;
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
                    spacing = 10;
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
