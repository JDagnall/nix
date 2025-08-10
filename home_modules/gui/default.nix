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
    imports = [ ./firefox.nix ];
    # gui packages that only need to be installed
    options = {
        gui.nwg-look.enable = mkEnableOption {
            default = false;
            description = "Install nwg-look";
        };
    };
    config =
        let
            inherit (config.gui) nwg-look;
        in
        {
            home.packages = [ ] ++ (if nwg-look.enable then [ pkgs.nwg-look ] else [ ]);
        };
}
