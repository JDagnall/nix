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
    };
}
