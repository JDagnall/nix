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

    imports = [
        ../../home-modules
        # ../../stylix.nix
    ];

    ### Configs
    shell.zsh.enable = true;
    shell.zsh.dircolors.enable = true;
    shell.zsh.direnv.enable = true;
    shell.bat.enable = true;
    shell.eza.enable = true;
    shell.fzf.enable = true;
    shell.zoxide.enable = true;

    langs.nix.enable = true;
    langs.python.enable = true;

    window-manager.hyprland.enable = true;

    term.wezterm.enable = true;

    ui.rofi.enable = true;
    ui.waybar.enable = true;
    ui.hyprpaper.enable = true;
    ui.hyprlock.enable = true;
    ui.hypridle.enable = true;
    ui.firefox.enable = true;
    ui.nwg-look.enable = false;
    ui.syncthingtray.enable = true;
    ui.spotify.enable = true;
    ui.slack.enable = false;
    ui.legcord.enable = true;
    ui.mako.enable = true;
    ui.swayosd.enable = true;
    ui.nm-applet.enable = true;
    ui.bt-applet.enable = true;

    tools.git.enable = true;
    tools.pipenv.enable = true;
    tools.mycli.enable = true;
    tools.keepassxc.enable = true;

    nixLoki.enable = true;

    # stylix.enableConfig = true;
    stylix.enableHomeConfig = true; # home-manager specific stylix

    ### Configs

    ### NixOs settings.
    # These arent real settings, these are just meant to represent relevant
    # parts of the NixOs config that I want to access in home-manager.
    # Could be possible to just import the whole NixOs config and reference it directly
    nixos-settings.network-manager.enabled = true;
    nixos-settings.blueman.enabled = true;
    nixos-settings.pipewire.enabled = true;
    nixos-settings.fprintd.enabled = true;
    nixos-settings.hyprland-uwsm.enabled = true;

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
    # programs.home-manager.enable = true;
}
