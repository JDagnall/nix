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
    shell.bat.enable = true;
    shell.eza.enable = true;
    shell.fzf.enable = true;
    shell.zoxide.enable = true;
    shell.ssh.enable = true;

    # these are generally bad, and I should use dev shells instead.
    # I keep python around cause it's handy and nix cause its native to the OS anyway
    langs.nix.enable = true;
    langs.python.enable = true;

    window-manager.hyprland.enable = true;

    term.wezterm.enable = true;

    ui.noctalia = {
        enable = true;
        lockScreen.enable = true;
        osd.enable = true;
        wallpaper.enable = true;
        notificationManager.enable = true;
        launcherShortcut = true;
        deviceProfile = "laptop";
        clipboardManager.enable = true;
    };

    ui.rofi.enable = true;
    ui.waybar.enable = false;
    ui.hyprpaper.enable = false;
    ui.hyprlock.enable = false;
    ui.hypridle.enable = true;
    ui.hypridle.profile = "laptop";
    ui.mako.enable = false;
    ui.swayosd.enable = false;
    ui.firefox.enable = true;
    ui.nwg-look.enable = false;
    ui.syncthingtray.enable = true;
    ui.spotify.enable = false;
    ui.slack.enable = true;
    ui.discord.enable = true;
    ui.nm-applet.enable = true;
    ui.bt-applet.enable = true;
    ui.vscode.enable = false;
    ui.obsidian.enable = true;
    ui.thunar.enable = true;
    ui.imv.enable = true;
    ui.hypr-screenshot.enable = true;
    ui.easyeffects.enable = false;
    ui.pavucontrol.enable = true;
    ui.vlc.enable = true;
    ui.seahorse.enable = true;
    ui.drawio.enable = true;
    ui.qbittorrent.enable = false;

    tools.git.enable = true;
    tools.mycli.enable = false;
    tools.keepassxc.enable = true;
    tools.keepmenu.enable = true;
    tools.gh-cli.enable = true;
    tools.nh.enable = true;
    tools.nix-index.enable = true;
    tools.nix-index.comma.enable = true;

    nixLoki.enable = true;

    stylix.enableHomeConfig = true; # home-manager specific stylix

    ### Configs

    # installed packages
    home.packages = [];

    home.file = {
        home_packages.text = let
            packages = map (p: "${p.name}") config.home.packages;
            sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
            formatted = builtins.concatStringsSep "\n" sortedUnique;
        in
            formatted;
    };
}
