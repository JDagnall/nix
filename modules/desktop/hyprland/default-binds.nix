{self, ...}: {
    flake.modules.homeManager.hyprland = {
        pkgs,
        config,
        ...
    }: {
        imports = with self.modules.homeManager; [desktop];
        config = {
            my.desktop.hyprland = let
                brightnessctl-bin = "${pkgs.brightnessctl}/bin/brightnessctl";
                wpctl-bin = "${pkgs.wireplumber}/bin/wpctl";
                playerctl-bin = "${pkgs.playerctl}/bin/playerctl";
                mod_key = "SUPER";
                # flags for the binds
                el_bind_flags = {
                    locked = true;
                    repeating = true;
                };
                l_bind_flags = {
                    locked = true;
                };
                terminal =
                    if (config.home.sessionVariables ? TERMINAL)
                    then config.home.sessionVariables.TERMINAL
                    else "${pkgs.wezterm}/bin/wezterm"; # just a default
            in {
                binds = [
                    {
                        bind = "${mod_key} + t";
                        action = "${terminal}";
                        isCommand = true;
                        flags = el_bind_flags;
                    }
                    {
                        bind = "XF86MonBrightnessUp";
                        action = "${brightnessctl-bin} -e4 -n2 set 5%+";
                        isCommand = true;
                        flags = el_bind_flags;
                    }
                    {
                        bind = "XF86MonBrightnessDown";
                        action = "${brightnessctl-bin} -e4 -n2 set 5%-";
                        isCommand = true;
                        flags = el_bind_flags;
                    }
                    {
                        bind = "XF86KbdBrightnessUp";
                        action = "${brightnessctl-bin} --device=smc::kbd_backlight s 10%+";
                        isCommand = true;
                        flags = el_bind_flags;
                    }
                    {
                        bind = "XF86KbdBrightnessDown";
                        action = "${brightnessctl-bin} --device=smc::kbd_backlight s 10%-";
                        isCommand = true;
                        flags = el_bind_flags;
                    }
                    {
                        bind = "XF86AudioRaiseVolume";
                        action = "${wpctl-bin} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
                        isCommand = true;
                        flags = el_bind_flags;
                    }
                    {
                        bind = "XF86AudioLowerVolume";
                        action = "${wpctl-bin} set-volume @DEFAULT_AUDIO_SINK@ 5%-";
                        isCommand = true;
                        flags = el_bind_flags;
                    }
                    {
                        bind = "XF86AudioMute";
                        action = "${wpctl-bin} set-mute @DEFAULT_AUDIO_SINK@ toggle";
                        isCommand = true;
                        flags = el_bind_flags;
                    }
                    {
                        bind = "XF86AudioMicMute";
                        action = "${wpctl-bin} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
                        isCommand = true;
                        flags = el_bind_flags;
                    }
                    {
                        bind = "XF86AudioNext";
                        action = "${playerctl-bin} next";
                        isCommand = true;
                        flags = l_bind_flags;
                    }
                    {
                        bind = "XF86AudioPause";
                        action = "${playerctl-bin} play-pause";
                        isCommand = true;
                        flags = l_bind_flags;
                    }
                    {
                        bind = "XF86AudioPlay";
                        action = "${playerctl-bin} play-pause";
                        isCommand = true;
                        flags = l_bind_flags;
                    }
                    {
                        bind = "XF86AudioPrev";
                        action = "${playerctl-bin} previous";
                        isCommand = true;
                        flags = l_bind_flags;
                    }
                ];
            };
        };
    };
}
