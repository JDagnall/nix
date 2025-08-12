{
    pkgs,
    lib,
    config,
    ...
}:
let
    inherit (lib) mkEnableOption;
in
{
    imports = [
        ./rofi.nix
        ./waybar
        ./swww.nix
        ./firefox.nix
        ./hyprpaper.nix
    ];
    # ui packages that only need to be installed
    options = {
        ui.nwg-look.enable = mkEnableOption {
            default = false;
            description = "Install nwg-look";
        };
    };
    config =
        let
            inherit (config.ui) nwg-look;
        in
        {
            home.packages = [ ] ++ (if nwg-look.enable then [ pkgs.nwg-look ] else [ ]);
        };
}
