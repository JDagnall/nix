{self, ...}: {
    flake.modules.homeManager.hypridle = {
        pkgs,
        config,
        osConfig,
        ...
    }: {
        imports = with self.modules.homeManager; [desktop];
        config = let
            # cfg = config.my.desktop.hypridle;
            deviceProfile = osConfig.my.hardware.device.profile or "desktop";
            desktopCfg = config.my.desktop;
        in {
            assertions = [
                {
                    assertion = desktopCfg.name == "hyprland";
                    message = ''
                        Hypridle cannot work without hyprland.
                        Please use enable hyprland or disable hypridle'';
                }
                {
                    assertion = deviceProfile != "headless";
                    message = "Hypridle only functions on non-headless devices.";
                }
            ];
            # hypridle execs commands after set timeouts of inacrivity,
            # it also can exec commands when `loginctl lock/unlock` commands are issued
            services.hypridle = let
                loginctl-bin = "${pkgs.systemd}/bin/loginctl";
                systemctl-bin = "${pkgs.systemd}/bind/systemctl";
                brightnessctl-bin = "${pkgs.brightnessctl}/bin/brightnessctl";
                hyprctl-bin = "${pkgs.hyprland}/bin/hyprctl";
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
                        on-timeout = ''${hyprctl-bin} dispatch "hl.dsp.dpms(action='disable')'';
                        on-resume = ''${hyprctl-bin} dispatch "hl.dsp.dpms(action='enable')'';
                    }
                    # lock session
                    {
                        timeout = 900; # 15 min
                        on-timeout = "${loginctl-bin} lock-session";
                    }
                    # suspend
                    {
                        timeout = 960; # 16 min
                        # in systemd pkg so not bothering to link to the package
                        on-timeout = "${systemctl-bin} suspend";
                    }
                ];
                desktop_profile = [
                    # fully turns the screen off
                    {
                        timeout = 300; # sec
                        on-timeout = ''${hyprctl-bin} dispatch "hl.dsp.dpms(action='disable')'';
                        on-resume = ''${hyprctl-bin} dispatch "hl.dsp.dpms(action='enable')'';
                    }
                    # lock session
                    {
                        timeout = 900; # 15 min
                        # in systemd pkg so not bothering to link to the package
                        on-timeout = "${loginctl-bin} lock-session";
                    }
                    # suspend after 30 mins
                    # {
                    # 	timeout = 1800; # sec
                    # 	on-timeout = "systemctl hibernate";
                    # }
                ];
            in {
                enable = true;
                settings = {
                    general = {
                        # runs on a dbus loginctl lock-session signal
                        lock_cmd = desktopCfg.lockScreen.command;

                        # on_lock_cmd = ""; # when the session is locked at all
                        # on_unlock_cmd = ""; # when the session is unlocked at all

                        # lock before suspend.
                        # in systemd pkg so not bothering to link to the package
                        before_sleep_cmd = "${loginctl-bin} lock-session";
                        # to avoid having to press a key twice to turn on the display.
                        # after_sleep_cmd = ''${hyprctl-bin} dispatch "hl.dsp.dpms(action='enable')'';

                        ignore_dbus_inhibit = false;
                        ignore_systemd_inhibit = false;
                        ignore_wayland_inhibit = false;
                        inhibit_sleep = 2; # normal
                    };
                    listener =
                        if deviceProfile == "desktop"
                        then desktop_profile
                        else laptop_profile;
                };
            };
        };
    };
}
