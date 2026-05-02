{
	config,
	# lib,
	pkgs,
	...
}: {
	# config ------------------------------
	display-manager.gdm.enable = true;
	boot-loader.grub.enable = true;
	window-manager.hyprland.enable = true;
	fonts.enable = true;
	sops.enable = true;
	evremap.enable = true;
	evremap.profile = "macbook";

	service.pipewire.enable = true;

	service.sshd.enable = true;
	service.sshd.james.authKeys.enable = true;

	service.syncthing = {
		enable = true;
		runAsUser = "james";
		devices.macmini-server.enable = true;
		folders = let
			shareDevices = ["MacMini-Server"];
		in {
			secure.enable = true;
			secure.share = shareDevices;
			docs.enable = true;
			docs.share = shareDevices;
		};
	};

	service.docker.enable = true;
	service.docker.groupUsers = ["james"];
	service.openvpn.enable = true;
	service.openvpn.PIA = true;
	service.tailscale.enable = false;
	service.jackett.enable = true;
	service.gnome-keyring.enable = true;

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

	# nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [];

	nix.settings.experimental-features = [
		"nix-command"
		"flakes"
	];

	security.polkit.enable = true;

	networking.networkmanager.enable = true;
	networking.hostName = "book";

	# dont power of on power key press
	services.logind.settings.Login = {
		HandlePowerKey = "ignore";
	};
	# battery managment
	services.upower.enable = true;

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
	# bt manager software
	services.blueman = {
		enable = true;
		# let home-manager deal with this,
		# new default actually manages to conflict with home-manager
		withApplet = false;
	};

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
		packages = map (p: "${p.name}") config.environment.systemPackages;
		sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
		formatted = builtins.concatStringsSep "\n" sortedUnique;
	in
		formatted;

	system.stateVersion = "25.11"; # Did you read the comment?
}
