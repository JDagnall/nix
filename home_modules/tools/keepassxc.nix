{ lib, config, ... }:
{
    options = {
        tools.keepassxc.enable = lib.mkEnableOption {
            default = false;
            description = "Enable keepassxc config";
        };
    };
    config = lib.mkIf config.tools.keepassxc.enable {
        programs.keepassxc = {
            enable = true;
            settings = {
                General = {
                    BackupBeforeSave = true;
                    BackupFilePathePattern = "{DB_FILENAME}.bak.kdbx";
                    ConfigVersion = 2;
                    GlobalAutoTypeKey = 84;
                    GlobalAutoTypeModifiers = 301989888;
                    MinimiseAfterUnlock = true;
                };
                Browser = {
                    enable = true;
                };
                GUI = {
                    ApplicationTheme = "dark";
                    ColorPasswords = true;
                    MinimiseOnClose = true;
                    MinimiseOnStartup = true;
                    MinimiseToTray = true;
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
    };
}
