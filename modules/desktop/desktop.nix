{lib, ...}: {
    flake.modules.homeManager.desktop = {...}: {
        key = "my/home/desktop";
        # These options are interface patterns for various desktop elements,
        # lockscreen, OSD etc. It is probably plausible that having multiple
        # of these enabled in one home config is actually valid, but that is
        # outside my use case for any of them.
        options = {
            my.desktop = {
                # the following could be defaulted to null, but I can't think of a scenario
                # where this module is imported and some WM or DE is not
                name = lib.mkOption {
                    type = lib.types.str;
                    description = "Name of the desktop program, e.g. hyprland, plasma etc. ";
                };
                autostarts = lib.mkOption {
                    default = [];
                    type = with lib.types; listOf str;
                    description = "List of commands to run as auto starts.";
                };
                displayServer = lib.mkOption {
                    type = lib.types.enum ["x" "wayland"];
                    description = ''
                        The graphics library the compositor uses. Likely set by the
                        window manager / desktop environment.
                    '';
                };
                idleManager = lib.mkOption {
                    type = with lib.types; nullOr str;
                    description = "The name of the idle manager.";
                    default = null;
                };
                lockScreen = {
                    name = lib.mkOption {
                        type = with lib.types; nullOr str;
                        description = "The name of the lock screen application.";
                        default = null;
                    };
                    command = lib.mkOption {
                        type = lib.types.str;
                        description = "Command to lock the screen";
                        default = "";
                    };
                };
                notificationManager = lib.mkOption {
                    type = with lib.types; nullOr str;
                    description = "The name of the notification manager.";
                    default = null;
                };
                wallpaperProvider = lib.mkOption {
                    type = with lib.types; nullOr str;
                    description = "The name of the wallpaper provider.";
                    default = null;
                };
                osd = lib.mkOption {
                    type = with lib.types; nullOr str;
                    description = "The name of the osd application.";
                    default = null;
                };
                polkitProvider = lib.mkOption {
                    type = with lib.types; nullOr str;
                    description = "The name of the polkit provider.";
                    default = null;
                };
            };
        };
        # could add warning here if any of these are missing. but I don't care to atm
    };
}
