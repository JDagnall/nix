{
    lib,
    config,
    ...
}: {
    options = {
        desktop-manager.xfce.enable = lib.mkEnableOption "Enable xfce user config.";
    };
    config = lib.mkIf config.desktop-manager.xfce.enable {
        stylix.targets.xfce = lib.mkIf config.stylix.enableHomeConfig {
            enable = true;
            fonts.enable = true;
        };
    };
}
