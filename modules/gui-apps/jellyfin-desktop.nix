{...}: {
    flake.modules.homeManager.jellyfin-desktop = {pkgs, ...}: {
        config = {
            home.packages = [pkgs.jellyfin-desktop];
            # TODO: need to find a way to get rid of the default desktop entry
            # that the package creates

            # Fixes current issues with the video player jellyfin-desktop is using
            # TODO: may be unnecesary https://github.com/NixOS/nixpkgs/pull/536760
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
    };
}
