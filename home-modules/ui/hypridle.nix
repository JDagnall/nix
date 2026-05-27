{
    pkgs,
    lib,
    config,
    inputs,
    ...
}: let
    inherit (lib) types mkIf mkEnableOption mkOption optionals optionalString;
in {
    options = {
        ui.hypridle.enable = mkEnableOption {
            description = "Enable hypridle config";
        };
        ui.hypridle.profile = mkOption {
            description = "The profile for the idle timeouts etc, currently one for a desktop and one for a laptop";
            type = types.enum ["laptop" "desktop"];
            default = "laptop";
        };
    };
    config = mkIf config.ui.hypridle.enable {
        assertions = [
            {
                assertion = config.window-manager.hyprland.enable;
                message = ''
                    Hypridle cannot work without hyprland enabled.
                    Please enable hyprland or disable hyprlock'';
            }
            {
                assertion =
                    (config.ui.hypridle.enable && config.tools.brightnessctl.enable) || !config.ui.hypridle.enable;
                message = ''
                    hypridle cannot work without brightnessctl. Please enable brightnessctl or disable hypridle'';
            }
        ];
        warnings =
            []
            ++ optionals (!config.tools.brightnessctl.enable && config.ui.hypridle.profile == "laptop")
            ["The brightness adjusting timers in hypridle will not work without brightnessctl"];
        # hypridle execs commands after set timeouts of inacrivity,
        # it also can exec commands when `loginctl lock/unlock` commands are issued
        services.hypridle = let
            brightnessctl-bin = "${pkgs.brightnessctl}/bin/brightnessctl";
            hyprctl-bin = "${pkgs.hyprland}/bin/hyprctl";
            # other wise it still installs the pacakges into the nix store even if they are not used which is annoying
            noctalia-bin = lib.optionalString config.ui.noctalia.enable "${inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/noctalia-shell";
            waybar-bin = lib.optionalString config.ui.waybar.enable "${pkgs.waybar}/bin/waybar";
            hyprlock-bin = lib.optionalString config.ui.hyprlock.enable "${pkgs.hyprlock}/bin/hyprlock";
            laptop_profile = [
                # dim screen after a period of inactivity
                {
                    timeout = 180; # sec
                    # set brightness low
                    on-timeout = "${brightnessctl-bin} -s set 10";
                    # set brightness back
                    on-resume = "${brightnessctl-bin} -r";
                }
                # do same for keyboard backlight
                {
                    timeout = 180; # sec
                    on-timeout = "${brightnessctl-bin} -sd rgb:kbd_backlight set 0";
                    # set brightness back
                    on-resume = "${brightnessctl-bin} -rd rgb:kbd_backlight";
                }
                # fully turns the screen off
                {
                    timeout = 300; # sec
                    on-timeout = "" + optionalString config.ui.waybar.enable "pidof ${waybar-bin} && pkill ${waybar-bin}; " + " ${hyprctl-bin} dispatch dpms off;";
                    on-resume = "" + optionalString config.ui.waybar.enable " exec ${waybar-bin};";
                }
                # lock session
                {
                    timeout = 900; # 15 min
                    on-timeout = "loginctl lock-session";
                }
                # suspend
                {
                    timeout = 960; # 16 min
                    # in systemd pkg so not bothering to link to the package
                    on-timeout = "systemctl suspend";
                }
            ];
            desktop_profile = [
                # fully turns the screen off
                {
                    timeout = 300; # sec
                    # temporary fix to stop waybar duping
                    on-timeout = "" + optionalString config.ui.waybar.enable "pidof ${waybar-bin} && pkill ${waybar-bin}; " + " ${hyprctl-bin} dispatch dpms off;";
                    on-resume = "" + optionalString config.ui.waybar.enable " exec ${waybar-bin};";
                }
                # lock session
                {
                    timeout = 900; # 15 min
                    # in systemd pkg so not bothering to link to the package
                    on-timeout = "loginctl lock-session";
                }
                # suspend after 30 mins
                # {
                # 	timeout = 1800; # sec
                # 	on-timeout = "systemctl hibernate";
                # }
            ];
            inherit (config.ui.hypridle) profile;
        in
            mkIf config.ui.hypridle.enable {
                enable = true;
                settings = {
                    general = {
                        # runs on a dbus loginctl lock-session signal
                        lock_cmd =
                            if config.ui.noctalia.enable
                            then "${noctalia-bin} ipc call lockScreen lock"
                            else if config.ui.hyprlock.enable
                            # avoid starting multiple hyprlock instances.
                            then "pidof ${hyprlock-bin} || ${hyprlock-bin}"
                            else "";
                        # on_lock_cmd = ""; # when the session is locked at all
                        # on_unlock_cmd = ""; # when the session is unlocked at all

                        # lock before suspend.
                        # in systemd pkg so not bothering to link to the package
                        before_sleep_cmd = "loginctl lock-session";
                        # to avoid having to press a key twice to turn on the display.
                        after_sleep_cmd = "${hyprctl-bin} dispatch dpms on";

                        ignore_dbus_inhibit = false;
                        ignore_systemd_inhibit = false;
                        ignore_wayland_inhibit = false;
                        inhibit_sleep = 2; # normal
                    };
                    listener =
                        if profile == "desktop"
                        then desktop_profile
                        else laptop_profile;
                };
            };
    };
}
