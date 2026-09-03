{
    lib,
    config,
    inputs,
    osConfig,
    ...
}: {
    # TODO: noctalia has been added to nixpkgs unstable and home-manager unstable
    # so the next time both are updated this can go
    imports = [
        inputs.noctalia.homeModules.default
    ];
    options = {
        ui.noctalia = {
            enable = lib.mkEnableOption "Enable nocatalia config.";
            systemd.enable = lib.mkEnableOption "Enable systemd unit activation." // {default = true;};
            autostart.enable = lib.mkEnableOption ''
                Autostart noctalia with an alternative program e.g. a window manager. Generally unecesary because of the systemd service
            '';
            lockScreen.enable = lib.mkEnableOption "Enable using noctalia as the idle manager.";
            wallpaper.enable = lib.mkEnableOption "Enable using noctalia as the wallpaper.";
            notificationManager.enable = lib.mkEnableOption "Enable using noctalia as the notification manager.";
            launcherShortcut = lib.mkEnableOption "Enable shortcut (probably Meta+D) for the launcher.";
            deviceProfile = lib.mkOption {
                default = "desktop";
                type = lib.types.enum ["desktop" "laptop"];
                description = "The device profile for things like the idle timeouts and battery monitoring, ect.";
            };
            polkit.enable = lib.mkEnableOption "Enable using noctalia as a polkit" // {default = osConfig.security.polkit.enable;};
        };
    };
    config = let
        noctaliaCfg = config.ui.noctalia;
    in
        lib.mkIf config.ui.noctalia.enable {
            assertions = [
                {
                    assertion = config.window-manager.hyprland.enable;
                    message = "Noctalia requires a wayland compositor.";
                }
                {
                    assertion = noctaliaCfg.enable != config.ui.waybar.enable;
                    message = "Noctalia and waybar should not be enabled together.";
                }
                {
                    assertion = noctaliaCfg.enable != config.ui.hyprpaper.enable;
                    message = "Noctalia and hyprpaper should not be enabled together.";
                }
                {
                    assertion = noctaliaCfg.enable != config.ui.hyprlock.enable;
                    message = "Noctalia and hyprlock should not be enabled together.";
                }
                {
                    assertion = noctaliaCfg.enable != config.ui.swayosd.enable;
                    message = "Noctalia and swayosd should not be enabled together.";
                }
                {
                    assertion = noctaliaCfg.enable != config.ui.mako.enable;
                    message = "Noctalia and mako should not be enabled together.";
                }
                {
                    assertion = !(noctaliaCfg.autostart.enable && noctaliaCfg.systemd.enable);
                    message = "The systemd service and autostart command should not be enabled together.";
                }
            ];
            warnings =
                []
                ++ lib.optionals (!osConfig.services.upower.enable && noctaliaCfg.deviceProfile == "laptop")
                ["Noctalia will be unable to provide battery information if services.upower is disabled in nixos config"]
                ++ lib.optionals (!(osConfig.services.tuned.enable || osConfig.services.power-profiles-daemon.enable) && noctaliaCfg.deviceProfile == "laptop")
                ["Noctalia will be unable to provide power profiles information without one of services.tuned or services.power-profiles-daemon in nixos config"];

            programs.noctalia = {
                enable = true;
                systemd.enable = noctaliaCfg.systemd.enable;
                validateConfig = true;
                settings = {
                    widget = {
                        launcher = {};
                        # control-center = {};
                        notifications = {
                            hide_when_no_unread = true;
                        };
                        network = {
                            vpn_status = "replace"; # both | hidden | replace
                            show_label = false;
                        };
                        privacy = {
                            hide_inactive = true;
                        };
                        clock = {
                            format = "{:%H:%M %a, %d %b}";
                            vertical_format = "{:%H\n%M}";
                            tooltip_format = "{:%A, %B %d, %Y}";
                        };
                        audio_visualizer = {
                            width = 100;
                        };
                        tray = {
                            drawer = true;
                        };
                        brightness = {
                            show_label = false;
                        };
                        battery = {
                            show_label = false;
                        };
                    };
                    bar = {
                        order = ["main"];
                        # can be any number of named bars
                        main = {
                            enabled = true;
                            position = "top";
                            auto_hide = false;
                            reserve_space = true; #compositor exclusion zone
                            # thickness = 34;
                            background_opacity = 0.8;
                            # border = "outline";
                            # border_width = 0.0;
                            # shadow = true;
                            # contact_shadow = false;
                            # panel_overlap = 1;
                            # radius = 12;
                            # radius_top_left = 12;
                            # radius_top_right = 12;
                            # radius_bottom_left = 12;
                            # radius_bottom_right = 12;
                            # concave_edge_corners = true;
                            # margin_ends = 100;
                            # margin_edge = 0;
                            # margin_opposite_edge = 0;
                            # padding = 14;
                            # widget_spacing = 6;
                            # hover_highlight = true;
                            # scale = 1.0;
                            # font_weight = 500;
                            capsule = true;
                            # capsule_fill = "surface_variant";
                            # capsule_thickness = 0.76;
                            # capsule_radius = 8.0;
                            # capsule_opacity = 1.0;
                            start = [
                                "launcher"
                                "clock"
                                "weather"
                                "sysmon"
                                "audio_visualizer"
                            ];
                            center = [
                                "workspaces"
                            ];
                            end =
                                [
                                    "tray"
                                    "notifications"
                                    "privacy"
                                    "clipboard"
                                ]
                                ++ [
                                    "volume"
                                    "network"
                                    "bluetooth"
                                ]
                                # ++ lib.optionals osConfig.services.tailscale.enable [{id = "plugin:tailscale";}]
                                ++ lib.optionals (noctaliaCfg.deviceProfile == "laptop") [
                                    "battery"
                                    "brightness"
                                ]
                                ++ [
                                    "control-center"
                                ];
                        };
                    };
                    shell = {
                        corner_radius_scale = 1.0; # 0 = square, 1 = default, 2 = extra rounded
                        time_format = "{:%H:%M}"; # default shell UI time format
                        date_format = "%A, %x"; # default shell UI date format
                        # looks way better as a mono font
                        font_family = lib.mkForce (lib.optionalString config.stylix.enableHomeConfig config.stylix.fonts.monospace.name);
                        offline_mode = false; # block all outgoing HTTP when true
                        panel_anchor_bar = "main";
                        telemetry_enabled = false; # send an anonymous startup ping
                        polkit_agent = noctaliaCfg.polkit.enable;
                        password_style = "default"; # default | random
                        settings_show_advanced = true; # show advanced settings by default in Settings
                        # settings_window_translucent = false
                        show_location = true;
                        # app_icon_colorize   = false
                        # app_icon_color      = "on_surface"
                        clipboard_enabled = true;
                        clipboard_history_max_entries = 100;
                        clipboard_keep_from_closed_apps = true; # keep the last copied item pasteable after the app you copied it from closes
                        clipboard_auto_paste = "auto"; # off | auto | ctrl_v | ctrl_shift_v | shift_insert
                        # clipboard_image_action_command = "";
                        shared_gl_context = true;
                        # lang                = "en"
                        avatar_path = builtins.fetchurl {
                            url = "https://cdnb.artstation.com/p/assets/images/images/035/450/685/large/ryth-asset.jpg";
                            name = "pyro_frog.jpg";
                            sha256 = "sha256:0gcnw96b43z2l5pm2iaarz6rxb7snxn8a8vldxvqn6hzppvl4wp8";
                        };
                        privacy = {
                            # mic_filter_regex = "";
                            # cam_filter_regex = "";
                            # screen_filter_regex = "";
                        };
                        animation = {
                            enabled = true;
                            # speed = 1.0;
                        };
                        launcher = {
                            categories = true;
                            show_icons = true;
                            compact = false;
                            app_grid = false;
                            # pinned = [];
                            providers = {};
                        };
                        panel = {
                            transparency_mode = "glass";
                        };
                    };
                    wallpaper = {
                        enabled = noctaliaCfg.wallpaper.enable;
                        fill_mode = "crop";
                    };
                    theme = {
                        source = lib.optionalString config.stylix.enableHomeConfig "custom";
                    };
                    backdrop = {enabled = false;};
                    notification = {
                        enable_daemon = noctaliaCfg.notificationManager.enable;
                    };
                    osd = {
                        kinds = {
                            volume = true;
                            volume_output = true;
                            volume_input = true;
                            brightness = true;
                            wifi = false;
                            bluetooth = false;
                            power_profile = false;
                            caffeine = false;
                            nightlight = false;
                            dnd = false;
                            lock_keys = false;
                            now_playing = false;
                            keyboard_layout = false;
                            privacy = true;
                        };
                    };
                    lockscreen = {enabled = noctaliaCfg.lockScreen.enable;};
                    system.monitor = {
                        enabled = true;
                        cpu_poll_seconds = 1000;
                        gpu_poll_seconds = 3000;
                        memory_poll_seconds = 1000;
                        disk_poll_seconds = 30000;
                        network_poll_seconds = 1000;
                    };
                    calendar = {enabled = false;};
                    control_center = {
                        calendar = {};
                    };
                    weather = {
                        enabled = true;
                        unit = "celsius";
                    };
                    audio = {};
                    brightness = {};
                    nightlight = {
                        enabled = noctaliaCfg.deviceProfile == "laptop";
                        temperature_day = "6500";
                        temperature_night = "4000";
                    };
                    location = {
                        auto_locate = true;
                        # address = "Toronto CA";
                    };
                    idle.behavior = {
                        lock = {enabled = false;};
                        screen-off = {enabled = false;};
                    };
                    keybinds = {
                        up = ["Up" "Ctrl+p"];
                        down = ["Down" "Ctrl+n"];
                        cancel = ["Escape" "Ctrl+c"];
                    };
                    dock = {enabled = false;};
                    desktop_widgets = {enabled = false;};
                    control_center = {
                        # shortcuts = [];
                    };
                    hooks = {};
                };
                # plugins = {
                # sources = [
                #     {
                #         enabled = true;
                #         name = "Official Noctalia Plugins";
                #         url = "https://github.com/noctalia-dev/noctalia-plugins";
                #     }
                # ];
                # states = {
                #     unicode-picker = {
                #         enabled = true;
                #         sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
                #     };
                #     file-search = lib.mkIf config.tools.fd.enable {
                #         enabled = true;
                #         sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
                #     };
                #     tailscale = lib.mkIf osConfig.services.tailscale.enable {
                #         enabled = true;
                #         sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
                #     };
                # };
                # version = 1;
            };
            # pluginSettings = {
            #     tailscale = {
            #         compactMode = true;
            #         terminalCommand = lib.mkIf (config.home.sessionVariables ? TERMINAL) config.home.sessionVariables.TERMINAL;
            #     };
            # };
            # };

            stylix.targets.noctalia.enable = config.stylix.enableHomeConfig;
        };
}
