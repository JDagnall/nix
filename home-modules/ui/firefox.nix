{
    lib,
    config,
    ...
}: {
    options = {
        ui.firefox.enable = lib.mkEnableOption {
            default = false;
            description = "Enable firefox module and config";
        };
    };
    config = lib.mkIf config.ui.firefox.enable {
        programs.firefox = {
            enable = true;
            profiles = {};
            configPath = "${config.xdg.configHome}/mozilla/firefox";
        };
    };
}
