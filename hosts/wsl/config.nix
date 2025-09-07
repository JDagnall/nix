{
	config,
	# lib,
	pkgs,
	...
}: {
	# config ------------------------------
	service.docker.enable = true;
	service.docker.groupUsers = ["james"];

	stylix.enableConfig = true;

	# nix of wsl seems to need this for some reason
	programs.dconf.enable = true;
	# config ------------------------------

	imports = [
		../../james.nix
		../../modules
		../../stylix.nix
	];

	environment.systemPackages = with pkgs; [home-manager];

	nix.settings.experimental-features = [
		"nix-command"
		"flakes"
	];

	networking.hostName = "wsl";

	services.openssh.enable = true;

	# garbage collector
	nix.gc = {
		automatic = true;
		dates = "weekly";
		persistent = true;
		randomizedDelaySec = "10min";
		options = "-d";
	};

	time.timeZone = "Australia/Brisbane";

	# use latest linux kernal
	boot.kernelPackages = pkgs.linuxPackages_latest;

	# adds list of currently used system packages to /etc/nixos/current-system-packages
	environment.etc."current-system-packages".text = let
		packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
		sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
		formatted = builtins.concatStringsSep "\n" sortedUnique;
	in
		formatted;

	system.stateVersion = "25.05"; # Did you read the comment?
}
