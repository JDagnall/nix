{
    lib,
    config,
    ...
}: {
    options = {
        ui.swayosd.enable = lib.mkEnableOption {
            description = "Enable swayosd config";
        };
    };
    config = lib.mkIf config.ui.swayosd.enable {
        services.swayosd = {
            enable = true;
            topMargin = 0.1; # 10% down from top
        };
    };
}
