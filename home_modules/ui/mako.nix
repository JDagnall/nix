{
    lib,
    config,
    ...
}:
{
    options = {
        ui.mako.enable = lib.mkEnableOption {
            description = "Enable mako config.";
        };
    };
    config = lib.mkIf config.ui.mako.enable {
        services.mako = {
            enable = true;
            settings = {
                anchor = "top-right";
            };
        };
        stylix.targets.mako.enable = true;
    };
}
