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
        ./jellyfin-desktop.nix
    ];
    # ui packages that only need to be installed
    options = {
        ui.nwg-look.enable = mkEnableOption "Install nwg-look";
        ui.spotify.enable = mkEnableOption "Install spotify";
        # can't use either of these electron apps till the fixes related
        # to this: https://github.com/NixOS/nixpkgs/issues/535580
        # are merged into unstable
        ui.vesktop.enable = mkEnableOption "Install vesktop";
        ui.legcord.enable = mkEnableOption "Install legcord";
        ui.discord.enable = mkEnableOption "Install discord";
        ui.slack.enable = mkEnableOption "Install slack";
        ui.pavucontrol.enable = mkEnableOption "Install pavucontrol";
        ui.drawio.enable = mkEnableOption "Install draw.io";
        ui.vlc.enable = mkEnableOption "Install vlc";
        ui.qbittorrent.enable = mkEnableOption "Install qbittorrent";
        ui.seahorse.enable = mkEnableOption "Install seahorse";
        ui.freetube.enable = mkEnableOption "Install freetube";
        ui.zotero.enable = mkEnableOption "Install zotero";
        ui.audacity.enable = mkEnableOption "Install audacity";
    };
    config = let
        inherit
            (config.ui)
            nwg-look
            spotify
            vesktop
            legcord
            discord
            slack
            pavucontrol
            drawio
            vlc
            qbittorrent
            seahorse
            freetube
            zotero
            audacity
            ;
    in {
        home.packages =
            []
            ++ optionals nwg-look.enable [pkgs.nwg-look]
            ++ optionals spotify.enable [pkgs.spotify]
            ++ optionals vesktop.enable [pkgs.vesktop]
            ++ optionals legcord.enable [pkgs.legcord]
            ++ optionals discord.enable [pkgs.discord]
            ++ optionals slack.enable [pkgs.slack]
            ++ optionals pavucontrol.enable [pkgs.pavucontrol]
            ++ optionals drawio.enable [pkgs.drawio]
            ++ optionals vlc.enable [pkgs.vlc]
            ++ optionals qbittorrent.enable [pkgs.qbittorrent]
            ++ optionals seahorse.enable [pkgs.seahorse]
            ++ optionals freetube.enable [pkgs.freetube]
            ++ optionals zotero.enable [pkgs.zotero]
            ++ optionals audacity.enable [pkgs.audacity];
    };
}
