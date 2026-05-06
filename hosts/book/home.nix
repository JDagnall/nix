{
	pkgs,
	config,
	...
}: {
	home.username = "james";
	home.homeDirectory = "/home/james";

	home.stateVersion = "25.11"; # Please read the comment before changing.

	imports = [
		../../home-modules
	];

	### Configs
	window-manager.hyprland.enable = true;
	window-manager.hyprland.enableTouchpadSwipe = true;

	term.wezterm.enable = true;

	shell.zsh.enable = true;
	shell.zsh.dircolors.enable = true;
	shell.zsh.direnv.enable = true;
	shell.zsh.vi-mode.enable = true;
	shell.bat.enable = true;
	shell.eza.enable = true;
	shell.fzf.enable = true;
	shell.zoxide.enable = true;
	shell.ssh.enable = true;

	tools.git.enable = true;
	tools.nh.enable = true;

	nixLoki.enable = true;
	nixLoki.theme = "tinted-nvim";

	langs.nix.enable = true;
	langs.python.enable = true;

	ui.noctalia = {
		enable = true;
		lockScreen.enable = true;
		osd.enable = true;
		wallpaper.enable = true;
		notificationManager.enable = true;
		launcherShortcut = true;
		clipboardManager.enable = true;
		deviceProfile = "laptop";
	};

	ui.rofi.enable = true;
	ui.waybar.enable = false;
	ui.mako.enable = false;
	ui.swayosd.enable = false;
	ui.hyprpaper.enable = false;
	ui.hyprlock.enable = false;
	ui.hypridle.enable = true;
	ui.hypridle.profile = "laptop";
	ui.nm-applet.enable = true;
	ui.bt-applet.enable = true;
	ui.hypr-screenshot.enable = true;
	ui.pavucontrol.enable = true;
	ui.firefox.enable = true;
	ui.syncthingtray.enable = true;
	ui.spotify.enable = true;
	ui.thunar.enable = true;
	ui.imv.enable = true;
	ui.vlc.enable = true;
	ui.brave.enable = true;
	ui.seahorse.enable = true;
	ui.freetube.enable = true;
	ui.jellyfin-desktop.enable = true;

	tools.keepassxc.enable = true;
	tools.keepmenu.enable = true;

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
