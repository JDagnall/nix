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
	term.wezterm.enable = true;

	shell.zsh.enable = true;
	shell.zsh.dircolors.enable = true;
	shell.zsh.direnv.enable = true;
	shell.zsh.vi-mode.enable = true;
	shell.bat.enable = true;
	shell.eza.enable = true;
	shell.fzf.enable = true;
	shell.zoxide.enable = true;
	shell.ssh.enable = false;

	tools.git.enable = true;
	tools.nh.enable = true;

	nixLoki.enable = true;
	nixLoki.theme = "tinted-nvim";

	langs.nix.enable = true;
	langs.python.enable = true;

	desktop-manager.plasma.enable = true;

	ui.firefox.enable = true;
	ui.syncthingtray.enable = false;
	ui.spotify.enable = true;
	ui.thunar.enable = true;
	ui.imv.enable = true;
	ui.vlc.enable = true;

	tools.keepassxc.enable = true;

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
