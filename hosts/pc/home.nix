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
    shell.zsh.vi-mode.enable = false;
    shell.bat.enable = true;
    shell.eza.enable = true;
    shell.fzf.enable = true;
    shell.zoxide.enable = true;
    shell.ssh.enable = true;

    # these are generally bad, and I should use dev shells instead.
    # I keep python around cause it's handy and nix cause its native to the OS anyway
    langs.nix.enable = true;
    langs.python.enable = true;
    langs.go.enable = false;
    langs.zig.enable = false;
    langs.rust.enable = false;
    langs.lua.enable = false;

    window-manager.hyprland.enable = true;
    window-manager.hyprland.monitors = [
        "desc:Acer, preferred, auto-right, 1"
        "desc:Lenovo, preferred, auto-left, 1"
    ];
    window-manager.hyprland.workspaces = [
        "2, monitor:desc:Acer, default:true"
        "1, monitor:desc:Lenovo, default:true"
    ];

    term.wezterm.enable = true;

    ui.noctalia = {
        enable = true;
        polkit.enable = true;
        lockScreen.enable = true;
        launcherShortcut = true;
        wallpaper.enable = true;
        notificationManager.enable = true;
        deviceProfile = "desktop";
    };

    ui.rofi.enable = true;
    ui.waybar.enable = false;
    ui.hyprpaper.enable = false;
    ui.hyprlock.enable = false;
    ui.hypridle.enable = true;
    ui.mako.enable = false;
    ui.swayosd.enable = false;
    ui.hypridle.profile = "desktop";
    ui.firefox.enable = true;
    ui.nwg-look.enable = false;
    ui.syncthingtray.enable = true;
    ui.spotify.enable = true;
    ui.slack.enable = true;
    ui.vesktop.enable = true;
    ui.nm-applet.enable = true;
    ui.bt-applet.enable = true;
    ui.vscode.enable = true;
    ui.obsidian.enable = true;
    ui.thunar.enable = true;
    ui.imv.enable = true;
    ui.hypr-screenshot.enable = true;
    ui.pavucontrol.enable = true;
    ui.drawio.enable = true;
    ui.vlc.enable = true;
    ui.seahorse.enable = true;
    ui.libreoffice.enable = true;
    ui.jellyfin-desktop.enable = true;
    ui.zotero.enable = true;

    tools.keepassxc.enable = true;
    tools.keepmenu.enable = true;

    tools.git.enable = true;
    tools.mycli.enable = false;
    tools.gh-cli.enable = true;
    tools.nh.enable = true;
    tools.ngrok.enable = true;
    tools.android-tools.enable = false;
    tools.nix-index.enable = true;
    tools.nix-index.comma.enable = true;
    tools.btop.enable = true;
    tools.btop.useGpuPkg = true;

    nixLoki.enable = true;
    nixLoki.theme = "tinted-nvim";

    gaming.proton.enable = true;
    gaming.lutris.enable = true;
    gaming.mangohud.enable = true;
    gaming.prism.enable = true;
    gaming.heroic.enable = true;
    gaming.protonplus.enable = true;

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
