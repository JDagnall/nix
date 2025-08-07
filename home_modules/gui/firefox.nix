{
    lib,
    config,
    ...
}:
{
    options = {
        gui.firefox.enable = lib.mkEnableOption {
            default = false;
            description = "enable firefox module and config";
        };
    };
    config = lib.mkIf config.gui.firefox.enable {
        programs.firefox = {
            enable = true;
            profiles = { };
        };
    };
}
