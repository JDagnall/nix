{
    pkgs,
    config,
    ...
}: {
    home.username = "james";
    home.homeDirectory = "/home/james";

    home.stateVersion = "25.05"; # Please read the comment before changing.

    imports = [
        ../../home-modules
    ];

    ### Configs
    shell.zsh.enable = true;
    shell.zsh.dircolors.enable = true;
    shell.zsh.direnv.enable = true;
    shell.zsh.vi-mode.enable = true;
    shell.bat.enable = true;
    shell.eza.enable = true;
    shell.fzf.enable = true;
    shell.zoxide.enable = true;
    shell.ssh.enable = true;

    langs.nix.enable = true;
    langs.python.enable = true;

    tools.git.enable = true;
    tools.gh-cli.enable = true;
    tools.nh.enable = true;

    nixLoki.enable = true;
    nixLoki.theme = "tinted-nvim";
    # nixLoki.enableWezterm = false;

    ### Configs

    # installed packages
    home.packages = [];

    home.file = {
        home_packages.text = let
            packages = builtins.map (p: "${p.name}") config.home.packages;
            sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
            formatted = builtins.concatStringsSep "\n" sortedUnique;
        in
            formatted;
    };
}
