{ lib, config, ... }:
{
    options = {
        tools.keepassxc.enable = lib.mkEnableOption {
            default = false;
            description = "Enable keepassxc config";
        };
        tools.keepassxc.autostart = lib.mkOption {
            type = lib.types.bool;
            default = config.tools.keepassxc.enable;
            description = ''
                Enable autostart for keepassxc. Configured in 
                whichever enabled config should be responsible for autostarts.'';
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
