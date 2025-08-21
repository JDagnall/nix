{
    pkgs,
    lib,
    config,
    osConfig,
    ...
}:
let
    inherit (lib)
        mkIf
        mkEnableOption
        mkOption
        types
        optionals
        ;
    inherit (config.tools) keepassxc keepmenu;
in
{
    options = {
        tools.keepassxc.enable = mkEnableOption {
            description = "Enable keepassxc config";
        };
        tools.keepmenu.enable = mkEnableOption {
            description = "Enable keepmenu. If rofi is enabled, it will be enabled as a plugin there aswell";
        };
        tools.keepassxc.autostart = mkOption {
            type = types.bool;
            default = keepassxc.enable;
            description = ''
                Enable autostart for keepassxc. Configured in 
                whichever enabled config should be responsible for autostarts.'';
        };
    };
    config = mkIf keepassxc.enable {
        programs.keepassxc = {
            enable = true;
            settings = {
                General = {
                    BackupBeforeSave = true;
                    BackupFilePathePattern = "{DB_FILENAME}.bak.kdbx";
                    ConfigVersion = 2;
                    GlobalAutoTypeKey = 65;
                    GlobalAutoTypeModifiers = 100663296;
                    MinimiseAfterUnlock = true;
                };
                Browser = {
                    Enabled = true;
                };
                GUI = {
                    ApplicationTheme = "dark";
                    ColorPasswords = true;
                    MinimizeOnClose = true;
                    MinimizeOnStartup = true;
                    MinimizeToTray = true;
                    MonospaceNotes = true;
                    ShowTrayIcon = true;
                    TrayIconAppearance = "colorful";
                };
                Security = {
                    ClearClipboardTimeout = 30;
                    LockDatabaseScreenLock = false;
                };
            };
        };

        assertions = [
            {
                assertion = (config.ui.rofi.enable || !keepmenu.enable);
                message = "Keepmenu requires rofi. Please enable rofi or disable keepmenu.";
            }
        ];

        home.packages =
            [ ]
            ++ optionals keepmenu.enable [
                pkgs.keepmenu
            ]
            ++ optionals (config.window-manager.hyprland.enable && keepmenu.enable) [
                pkgs.wl-clipboard # neeeded for clipboard on wayland
                pkgs.wtype # needed for autotype on wayland
            ];
        # create config file for keepmenu
        xdg.configFile."keepmenu/config.ini" =
            let
                inherit (lib) generators;
                inherit (config) term window-manager;
                inherit (osConfig.service.syncthing.folders) secure;
                inherit (osConfig.service.syncthing) dataDir;
                settings = {
                    dmenu = {
                        dmenu_command = "rofi";
                    };
                    dmenu_passphrase = {
                        obscure = true;
                    };
                    database = {
                        autotype_default = "{USERNAME}{DELAY 200}{TAB}{PASSWORD}{ENTER}";
                        pw_cache_period_min = 60;
                    }
                    // optionals secure.enable {
                        # could add more databases like this
                        database_1 = "${dataDir}/secure/Passwords.kdbx";
                    }
                    // optionals term.wezterm.enable {
                        terminal = "wezterm";
                    }
                    // optionals window-manager.hyprland.enable {
                        type_library = "wtype";
                    };
                };
                iniSettings = generators.toINI { } settings;
            in
            mkIf config.tools.keepmenu.enable {
                text = iniSettings;
            };
    };
}
