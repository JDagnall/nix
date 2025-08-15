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
                default-timeout = 2000; # ms
                ignore-timeout = 1; # always use default-timeout
            };
        };
        stylix.targets.mako.enable = true;
    };
}
