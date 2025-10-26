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

	langs.nix.enable = true;
	langs.python.enable = true;

	window-manager.hyprland.enable = true;

	term.wezterm.enable = true;

	ui.rofi.enable = true;
	ui.waybar.enable = true;
	ui.hyprpaper.enable = true;
	ui.hyprlock.enable = true;
	ui.hypridle.enable = true;
	ui.hypridle.profile = "desktop";
	ui.firefox.enable = true;
	ui.nwg-look.enable = false;
	ui.syncthingtray.enable = true;
	ui.spotify.enable = true;
	ui.slack.enable = true;
	ui.legcord.enable = true;
	ui.mako.enable = true;
	ui.swayosd.enable = true;
	ui.nm-applet.enable = true;
	ui.bt-applet.enable = true;
	ui.vscode.enable = true;
	ui.obsidian.enable = true;
	ui.thunar.enable = true;
	ui.imv.enable = true;
	ui.hypr-screenshot.enable = true;
	ui.easyeffects.enable = true;
	ui.pavucontrol.enable = true;

	tools.git.enable = true;
	tools.pipenv.enable = true;
	tools.mycli.enable = true;
	tools.keepassxc.enable = true;
	tools.keepmenu.enable = true;
	tools.gh-cli.enable = true;
	tools.nh.enable = true;

	nixLoki.enable = true;

	stylix.enableHomeConfig = true; # home-manager specific stylix

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
