{lib, ...}: {
    flake.modules.homeManager.eza = {config, ...}: {
        config = {
            programs.eza = {
                enable = true;
                enableZshIntegration = config.programs.zsh.enable;
                extraOptions = ["--long" "--all"];
                git = true;
                icons = "auto";
                # theme = {}
            };
            home.shellAliases = {
                ls = lib.mkForce "eza";
                lt = "eza --tree --level 3 -I .git";
            };
        };
    };
}
