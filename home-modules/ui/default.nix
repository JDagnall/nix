{
    pkgs,
    lib,
    config,
    ...
}:
let
    inherit (lib) mkOption optionals types;
in
{
    imports = [
        ./rofi.nix
        ./waybar
        ./swww.nix
        ./firefox.nix
        ./hyprpaper.nix
        ./hyprlock.nix
        ./syncthingtray.nix
        ./mako.nix
        ./swayosd.nix
        ./applets.nix
    ];
    # ui packages that only need to be installed
    options = {
        ui.nwg-look.enable = mkOption {
            default = false;
            type = types.bool;
            description = "Install nwg-look";
        };
        ui.spotify.enable = mkOption {
            default = false;
            type = types.bool;
            description = "Install spotify";
        };
        ui.legcord.enable = mkOption {
            default = false;
            type = types.bool;
            description = "Install legcord";
        };
        ui.slack.enable = mkOption {
            default = false;
            type = types.bool;
            description = "Install slack";
        };
    };
    config =
        let
            inherit (config.ui)
                nwg-look
                spotify
                legcord
                slack
                ;
        in
        {
            home.packages =
                [ ]
                ++ optionals nwg-look.enable [ pkgs.nwg-look ]
                ++ optionals spotify.enable [ pkgs.spotify ]
                ++ optionals legcord.enable [ pkgs.legcord ]
                ++ optionals slack.enable [ pkgs.slack ];
        };
}
