{
	pkgs,
	# lib,
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

	tools.git.enable = true;
	tools.pipenv.enable = true;
	tools.mycli.enable = true;
	tools.gh-cli.enable = true;
	tools.nh.enable = true;
	tools.ngrok.enable = true;

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
