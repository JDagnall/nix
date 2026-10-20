{...}: {
    flake.modules.homeManager.easyeffects = {osConfig, ...}: {
        config = {
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
    };
}
