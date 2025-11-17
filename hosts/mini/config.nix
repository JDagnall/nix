{
	config,
	lib,
	pkgs,
	...
}: {
	# config ------------------------------
	boot-loader.systemd-boot.enable = true;
	fonts.enable = true;
	sops.enable = true;

	service.sshd.enable = true;
	service.sshd.james.authKeys.enable = true;

	service.syncthing = {
		enable = true;
		devices = {
			PC.enable = true;
			PC-windows.enable = true;
			framework.enable = true;
			macbook.enable = true;
			galaxy-s10e.enable = true;
		};
		folders = let
			shareDevices = ["PC" "PC-windows" "Framework" "Macbook" "Galaxy-s10e"];
		in {
			secure.enable = true;
			secure.share = shareDevices;
			classes.enable = true;
			classes.share = shareDevices;
			proj.enable = true;
			proj.share = shareDevices;
			wallpapers.enable = true;
			wallpapers.share = shareDevices;
		};
	};
	# override gui address so it can be accessed from the outside
	# set a gui login since its exposed, using options so that its easier to pass secrets
	services.syncthing.guiAddress = lib.mkForce "0.0.0.0:8384";
	networking.firewall.allowedTCPPorts = [8384];
	sops.secrets = let
		host = config.networking.hostName;
	in
		lib.mkIf config.sops.enable {
			"syncthing/gui-user" = {
				sopsFile = ../../secrets/${host}/syncthing.yaml;
				owner = config.services.syncthing.user;
				restartUnits = ["syncthing.service"];
			};
			"syncthing/gui-password" = {
				sopsFile = ../../secrets/${host}/syncthing.yaml;
				owner = config.services.syncthing.user;
				restartUnits = ["syncthing.service"];
			};
		};
	services.syncthing.extraFlags = [
		"--gui-user=\"$(cat ${config.sops.secrets."syncthing/gui-user".path})\""
		"--gui-password=\"$(cat ${config.sops.secrets."syncthing/gui-password".path})\""
	];

	stylix.enableConfig = true;

	# config ------------------------------

	imports = [
		# Include the results of the hardware scan.
		./hardware-configuration.nix
		../../james.nix
		../../modules
		../../stylix.nix
		../../sops.nix
		./stylix.nix
	];

	environment.systemPackages = with pkgs; [home-manager];

	nix.settings.experimental-features = [
		"nix-command"
		"flakes"
	];
	networking.networkmanager.enable = true;
	networking.hostName = "mini";

	# garbage collector
	nix.gc = {
		automatic = true;
		dates = "weekly";
		persistent = true;
		randomizedDelaySec = "10min";
		options = "-d";
	};

	time.timeZone = "Australia/Brisbane";

	# Select internationalisation properties.
	i18n.defaultLocale = "en_GB.UTF-8";

	i18n.extraLocaleSettings = {
		LC_ADDRESS = "en_AU.UTF-8";
		LC_IDENTIFICATION = "en_AU.UTF-8";
		LC_MEASUREMENT = "en_AU.UTF-8";
		LC_MONETARY = "en_AU.UTF-8";
		LC_NAME = "en_AU.UTF-8";
		LC_NUMERIC = "en_AU.UTF-8";
		LC_PAPER = "en_AU.UTF-8";
		LC_TELEPHONE = "en_AU.UTF-8";
		LC_TIME = "en_AU.UTF-8";
	};

	console = {
		font = "Lat2-Terminus16";
		keyMap = "us";
		#useXkbConfig = true; # use xkb.options in tty.
	};

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
