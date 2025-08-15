# home manager specific stylix
{
    lib,
    config,
    pkgs,
    ...
}:
{
    options = {
        stylix.enableHomeConfig = lib.mkEnableOption {
            description = "Enable home-manager specific stylix config.";
        };
        stylix.gtk.enable = lib.mkOption {
            default = true;
            description = "Enable gtk theming with stylix, defaults to true.";
            type = lib.types.bool;
        };
        stylix.qt.enable = lib.mkOption {
            default = true;
            description = "Enable qt theming with stylix, defaults to true.";
            type = lib.types.bool;
        };
    };
    config = lib.mkIf config.stylix.enableHomeConfig {
        stylix = {
            # icons aren't in nixos stylix for some reason
            icons = {
                enable = true;
                light = "Qogir";
                dark = "Qogir";
                package = pkgs.qogir-icon-theme;
            };
            targets = {
                gtk = lib.mkIf config.stylix.gtk.enable {
                    enable = true;
                    # extra css for gtk 3 and 4 .css
                    # extraCss = "";
                    # flatpakSupport.enable = true;
                };
                qt = lib.mkIf config.stylix.qt.enable {
                    enable = true;
                    # platform = "";
                };
            };
        };
    };
}
