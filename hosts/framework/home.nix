{
    pkgs,
    # lib,
    config,
    ...
}:
{
    home.username = "james";
    home.homeDirectory = "/home/james";

    home.stateVersion = "25.05"; # Please read the comment before changing.

    imports = [ ../../home_modules ];

    ### Configs
    shell.zsh.enable = true;
    shell.zsh.dircolors.enable = true;
    shell.zsh.direnv.enable = true;
    shell.bat.enable = true;
    shell.eza.enable = true;
    shell.fzf.enable = true;
    shell.zoxide.enable = true;

    tools.git.enable = true;
    nixLoki.enable = true;

    term.wezterm.enable = true;
    ui.rofi.enable = true;
    ui.waybar.enable = true;

    window-manager.hyprland.enable = true;
    ### Configs

    # installed packages
    home.packages = [ ];

    home.file = {
        home_packages.text =
            let
                packages = builtins.map (p: "${p.name}") config.home.packages;
                sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
                formatted = builtins.concatStringsSep "\n" sortedUnique;
            in
            formatted;
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
}
