{...}: {
    flake.modules.homeManager.firefox = {config, ...}: {
        config = {
            programs.firefox = {
                enable = true;
                profiles = {};
                configPath = "${config.xdg.configHome}/mozilla/firefox";
            };
        };
    };
}
