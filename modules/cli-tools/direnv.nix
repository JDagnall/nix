{inputs, ...}: {
    flake.modules.homeManager.direnv = {...}: {
        # direnv-instant needs an import cause its not in home-manager
        imports = [inputs.direnv-instant.homeModules.direnv-instant];
        config = {
            programs.direnv = {
                enable = true;
                enableZshIntegration = true;
                # written to .toml config file
                config = {
                    hide_env_diff = true;
                };
                silent = false;
            };
            # makes it so that there is no loading time stepping into an env
            programs.direnv-instant.enable = true;
        };
    };
}
