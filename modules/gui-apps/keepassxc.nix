# TODO: this module imports my.desktop, if I want a module that is just the cli
# utils for a headless server, I should make another module
{
    self,
    lib,
    ...
}: {
    flake.modules.homeManager.keepassxc = {
        pkgs,
        config,
        ...
    }: {
        key = "my/home/keepassxc"; # because it is imported by keepmenu and does set options
        options = {
            my.gui-apps.keepassxc = {
                autostart = lib.mkEnableOption "Autostart the program.";
            };
        };
        config = let
            cfg = config.my.gui-apps.keepassxc;
        in {
            my.desktop = lib.mkIf cfg.autostart {
                autostarts = [
                    "${pkgs.keepassxc}/bin/keepassxc --minimized &"
                ];
            };
            programs.keepassxc = {
                enable = true;
                autostart = false; # using my auto start settings
                settings = {
                    General = {
                        BackupBeforeSave = true;
                        BackupFilePathPattern = "{DB_FILENAME}.bak.kdbx";
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
                    # freedesktop secret service implementation, requires enabled groups in databases
                    FdoSecrets = {
                        Enabled = false;
                        ShowNotification = true;
                        ConfirmDeleteItem = false;
                        ConfirmAccessItem = false;
                        UnlockBeforeSearch = true;
                    };
                };
            };
        };
    };
    flake.modules.homeManager.keepmenu = {
        pkgs,
        config,
        ...
    }: {
        imports = with self.modules.homeManager; [keepassxc rofi desktop];
        config = {
            home.packages =
                [
                    pkgs.keepmenu
                ]
                ++ lib.optionals (config.my.desktop.displayServer == "wayland") [
                    pkgs.wl-clipboard # neeeded for clipboard on wayland
                    pkgs.wtype # needed for autotype on wayland
                ];
            # create config file for keepmenu
            xdg.configFile."keepmenu/config.ini" = let
                settings = {
                    dmenu = {
                        dmenu_command = "rofi";
                    };
                    dmenu_passphrase = {
                        obscure = true;
                    };
                    database =
                        {
                            autotype_default = "{USERNAME}{DELAY 200}{TAB}{PASSWORD}{ENTER}";
                            pw_cache_period_min = 60;
                        }
                        // lib.optionalAttrs (config.home.sessionVariables ? TERMINAL) {
                            terminal = config.home.sessionVariables.TERMINAL;
                        }
                        // lib.optionalAttrs (config.my.desktop.displayServer == "wayland") {
                            type_library = "wtype";
                        };
                };
                iniSettings = lib.generators.toINI {} settings;
            in {
                text = iniSettings;
            };
        };
    };
}
