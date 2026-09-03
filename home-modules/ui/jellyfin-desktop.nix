{
    pkgs,
    lib,
    config,
    ...
}: {
    options = {
        ui.jellyfin-desktop.enable = lib.mkEnableOption "Install jellyfin-desktop";
    };
    config = lib.mkIf config.ui.jellyfin-desktop.enable {
        home.packages = [pkgs.jellyfin-desktop];
        xdg.desktopEntries = {
            jellyfin-desktop = {
                name = "Jellyfin";
                comment = "Desktop client for Jellyfin";
                exec = "QT_QPA_PLATFORM=xcb jellyfin-desktop";
                icon = "org.jellyfin.JellyfinDesktop";
                terminal = false;
                type = "Application";
                categories = ["AudioVideo" "Video" "Player" "TV"];
                settings = {
                    StartupWMClass = "org.jellyfin.JellyfinDesktop";
                    Version = "1.0";
                };
                actions = {
                    "Desktop-Fullscreen" = {
                        exec = "QT_QPA_PLATFORM=xcb jellyfin-desktop --fullscreen --desktop";
                    };

                    "Desktop-Windowed" = {
                        exec = "QT_QPA_PLATFORM=xcb jellyfin-desktop --windowed --desktop";
                    };

                    "TV-Fullscreen" = {
                        exec = "QT_QPA_PLATFORM=xcb jellyfin-desktop --fullscreen --tv";
                    };

                    "TV-Windowed" = {
                        exec = "QT_QPA_PLATFORM=xcb jellyfin-desktop --windowed --tv";
                    };
                };
            };
        };
    };
}
