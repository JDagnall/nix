{
    lib,
    config,
    osConfig,
    ...
}: {
    options = {
        ui.easyeffects.enable = lib.mkEnableOption {
            description = "Enable easyeffects config. An audio mixer.";
        };
    };
    config = lib.mkIf config.ui.easyeffects.enable {
        assertions = [
            {
                assertion = osConfig.programs.dconf.enable;
                message = "Easy effects config requires dconf to be enabled.";
            }
        ];
        services.easyeffects = {
            enable = true;
            # extraPresets = {};
            # preset = "";
        };
    };
}
