{
    pkgs,
    lib,
    config,
    ...
}: let
    inherit (lib) mkEnableOption optionals;
in {
    imports = [
        ./rofi.nix
        ./waybar
        ./swww.nix
        ./firefox.nix
        ./hyprpaper.nix
        ./hyprlock.nix
        ./hypridle.nix
        ./syncthingtray.nix
        ./mako.nix
        ./swayosd.nix
        ./applets.nix
        ./vscode.nix
        ./obsidian.nix
        ./thunar.nix
        ./imv.nix
        ./hypr-screenshot.nix
        ./easyeffects.nix
        ./brave.nix
        ./noctalia.nix
        ./libresuite.nix
    ];
    # ui packages that only need to be installed
    options = {
        ui.nwg-look.enable = mkEnableOption "Install nwg-look";
        ui.spotify.enable = mkEnableOption "Install spotify";
        ui.legcord.enable = mkEnableOption "Install legcord";
        ui.slack.enable = mkEnableOption "Install slack";
        ui.pavucontrol.enable = mkEnableOption "Install pavucontrol";
        ui.drawio.enable = mkEnableOption "Install draw.io";
        ui.vlc.enable = mkEnableOption "Install vlc";
        ui.qbittorrent.enable = mkEnableOption "Install qbittorrent";
        ui.seahorse.enable = mkEnableOption "Install seahorse";
        ui.freetube.enable = mkEnableOption "Install freetube";
        ui.jellyfin-desktop.enable = mkEnableOption "Install jellyfin-desktop";
        ui.zotero.enable = mkEnableOption "Install zotero";
        ui.audacity.enable = mkEnableOption "Install audacity";
    };
    config = let
        inherit
            (config.ui)
            nwg-look
            spotify
            legcord
            slack
            pavucontrol
            drawio
            vlc
            qbittorrent
            seahorse
            freetube
            jellyfin-desktop
            zotero
            audacity
            ;
    in {
        home.packages =
            []
            ++ optionals nwg-look.enable [pkgs.nwg-look]
            ++ optionals spotify.enable [pkgs.spotify]
            ++ optionals legcord.enable [pkgs.legcord]
            ++ optionals slack.enable [pkgs.slack]
            ++ optionals pavucontrol.enable [pkgs.pavucontrol]
            ++ optionals drawio.enable [pkgs.drawio]
            ++ optionals vlc.enable [pkgs.vlc]
            ++ optionals qbittorrent.enable [pkgs.qbittorrent]
            ++ optionals seahorse.enable [pkgs.seahorse]
            ++ optionals freetube.enable [pkgs.freetube]
            ++ optionals jellyfin-desktop.enable [pkgs.jellyfin-desktop]
            ++ optionals zotero.enable [pkgs.zotero]
            ++ optionals audacity.enable [pkgs.audacity];
    };
}
