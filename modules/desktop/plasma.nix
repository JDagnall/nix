{
    self,
    lib,
    inputs,
    ...
}: {
    flake.modules.nixos.plasma = {pkgs, ...}: {
        # imports = [inputs.plasma-manager.nixosModules.default];
        services.desktopManager.plasma6 = {
            enable = true;
            enableQt5Integration = true;
        };
        services.displayManager.sddm = {
            enable = lib.mkDefault true;
            wayland.enable = true;
            wayland.compositor = "kwin";
        };
        qt = {
            enable = true;
            platformTheme = "qt5ct";
            style = "kvantum";
        };
        hardware = {
            # Opengl
            graphics.enable = true;
        };

        # XDG portal
        xdg.portal.enable = true;
        xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

        # environment.systemPackages = with pkgs; [];
    };

    # TODO: need an interface pattern in nixos so that the home-manager module
    # can check if the nixos module is imported

    flake.modules.homeManager.plasma = {config, ...}: {
        imports = with self.modules.homeManager; [
            inputs.plasma-manager.homeModules.plasma-manager
            stylix-interface
            desktop
        ];
        # haven't used this at all in ages, likely very outdated
        config = {
            my.desktop = {
                name = "plasma";
                displayServer = "wayland";
                # TODO: likely plasma is also a notification provider, etc
                # but again im not using it rn and don't care to test what it
                # is and isn't
            };
            programs.plasma = {
                enable = true;
                overrideConfig = false;
                # resetFiles = []; # wipe plasma config files on each gen
                # resetFilesExclude = [];
                configFile = {};
                desktop = {
                    icons = {
                        size = 2; # 0-7
                    };
                };
                hotkeys = {
                    commands = {
                        term = lib.mkIf config.term.wezterm.enable {
                            command = "wezterm";
                            key = "Meta+T";
                            comment = "Open wezterm";
                        };
                    };
                };
                shortcuts = {
                    kwin = {
                        "Switch to Desktop 1" = "Meta+1";
                        "Switch to Desktop 2" = "Meta+2";
                        "Window to Desktop 1" = "Meta+!";
                        "Window to Desktop 2" = "Meta+@";
                    };
                };
                krunner = {
                    position = "center";
                    shortcuts.launch = "Meta+D";
                };
                kscreenlocker = {
                    lockOnResume = true;
                    autoLock = true;
                    passwordRequired = true;
                    timeout = 5; # min
                };
                kwin = {
                    borderlessMaximizedWindows = true;
                    effects = {
                        blur.enable = true;
                        desktopSwitching.animation = "slide";
                    };
                    nightLight = {
                        enable = true;
                        mode = "times";
                        time = {
                            morning = "08:00";
                            evening = "22:00";
                        };
                    };
                    titlebarButtons = {
                        left = ["more-window-actions" "application-menu"];
                        right = ["minimize" "maximize" "close"];
                    };
                    virtualDesktops = {
                        number = 2;
                    };
                };
                powerdevil = {
                    AC = {
                        autoSuspend = {
                            action = "sleep";
                            idleTimeout = 600;
                        };
                        dimDisplay = {
                            enable = true;
                            idleTimeout = 60;
                        };
                        dimKeyboard.enable = true;
                        displayBrightness = 10;
                        keyboardBrightness = 10;
                        inhibitLidActionWhenExternalMonitorConnected = true;
                        powerButtonAction = "showLogoutScreen";
                        powerProfile = "performance";
                        whenLaptopLidClosed = "sleep";
                        whenSleepingEnter = "hybridSleep";
                    };
                    battery = {
                        autoSuspend = {
                            action = "sleep";
                            idleTimeout = 600;
                        };
                        dimDisplay = {
                            enable = true;
                            idleTimeout = 60;
                        };
                        dimKeyboard.enable = true;
                        displayBrightness = 10;
                        keyboardBrightness = 10;
                        inhibitLidActionWhenExternalMonitorConnected = true;
                        powerButtonAction = "showLogoutScreen";
                        powerProfile = "powerSaving";
                        whenLaptopLidClosed = "sleep";
                        whenSleepingEnter = "hybridSleep";
                    };
                    lowBattery = {
                        autoSuspend = {
                            action = "hibernate";
                            idleTimeout = 60;
                        };
                        dimDisplay = {
                            enable = true;
                            idleTimeout = 20;
                        };
                        dimKeyboard.enable = true;
                        displayBrightness = 10;
                        keyboardBrightness = 10;
                        inhibitLidActionWhenExternalMonitorConnected = true;
                        powerButtonAction = "showLogoutScreen";
                        powerProfile = "powerSaving";
                        whenLaptopLidClosed = "sleep";
                        whenSleepingEnter = "hybridSleep";
                    };
                };
                panels = [
                    {
                        location = "bottom";
                        hiding = "windowsgobelow";
                        lengthMode = "fill";
                        opacity = "translucent";
                        screen = "all";
                        widgets = [
                            {
                                name = "org.kde.plamsa.kickoff";
                                config = {
                                    General = {
                                        icon = "nix-snowflake-white";
                                        alphaSort = true;
                                    };
                                };
                            }
                            {
                                iconTasks = {
                                    launchers = [];
                                };
                            }
                            "org.kde.plasma/marginseparator"
                            {
                                systemTray.items = {
                                    shown = [
                                        "org.kde.plasma.battery"
                                        "org.kde.plasma.bluetooth"
                                        "org.kde.plasma.networkmanagement"
                                        "org.kde.plasma.volume"
                                    ];
                                    hidden = [];
                                };
                            }
                            {
                                digitalClock = {
                                    calendar.firstDayOfWeek = "monday";
                                    time.format = "12h";
                                };
                            }
                        ];
                    }
                ];
                session.general.askForConfirmationOnLogout = false;
                session.sessionRestore.restoreOpenApplicationsOnLogin = "onLastLogout";
            };
            stylix.targets = config.my.stylix.enabled {
                kde = {
                    enable = true;
                    useWallpaper = true;
                    # decorations = "";
                };
                qt.enable = lib.mkDefault true;
            };
        };
    };
}
