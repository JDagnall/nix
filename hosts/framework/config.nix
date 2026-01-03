{
	config,
	# lib,
	pkgs,
	...
}: {
	# config ------------------------------
	display-manager.gdm.enable = true;
	window-manager.hyprland.enable = true;
	boot-loader.grub.enable = true;
	fonts.enable = true;
	sops.enable = true;
	evremap.enable = true;
	evremap.profile = "framework";

	service.pipewire.enable = true;

	service.syncthing = {
		enable = true;
		runAsUser = "james";
		devices.macmini-server.enable = true;
		folders = let
			shareDevices = ["MacMini-Server"];
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

	service.docker.enable = true;
	service.docker.groupUsers = ["james"];
	service.fprintd.enable = false;
	service.openvpn.enable = true;
	service.sshd.enable = true;
	service.sshd.james.authKeys.enable = true;

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
	networking.hostName = "framework";

	# bluetooth
	hardware.bluetooth = {
		enable = true;
		powerOnBoot = true; # turn bt device on
		settings = {
			General = {
				Experimental = true; # Enables showing battery of bt devices
			};
		};
	};
	services.blueman.enable = true; # bt manager software

	services.flatpak.enable = true;

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
