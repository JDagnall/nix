{
    lib,
    config,
    ...
}: let
    cfg = config.display-manager.noctalia-greeter;
in {
    options = {display-manager.noctalia-greeter.enable = lib.mkEnableOption "Enable noctalia-greeter.";};
    config = lib.mkIf cfg.enable {
        services.displayManager.noctalia-greeter = {
            enable = true;
            # package = ;
            cursorTheme = lib.mkIf config.stylix.enableConfig {
                name = config.stylix.cursor.name;
                package = config.stylix.cursor.package;
            };
            # extraArgs = [];
            settings = {
                cursor.size = lib.mkIf config.stylix.enableConfig config.stylix.cursor.size;
            };
        };
    };
}
