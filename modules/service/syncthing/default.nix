{
	lib,
	config,
	...
}: let
	inherit
		(lib)
		mkIf
		mkEnableOption
		mkOption
		types
		;
in {
	options = {
		service.syncthing.enable =
			mkEnableOption {
				default = false;
				description = "Enable syncthing config";
			};
		service.syncthing.user =
			mkOption {
				default = null;
				type = with types; nullOr str;
				description = "User the syncthing service should be run under. REQUIRED";
			};
		service.syncthing.group =
			mkOption {
				default = null;
				type = with types; nullOr str;
				description = "Group the syncthing service should be run under. REQUIRED";
			};
		service.syncthing.dataDir =
			mkOption {
				default = null;
				type = types.path;
				description = "Path that synced folders should be stored in by default. REQUIRED";
			};
		service.syncthing.configDir =
			mkOption {
				default = null;
				type = types.path;
				description = "Path that the config should be stored in by default. REQUIRED";
			};
		service.syncthing.devices.macmini-server.enable =
			mkEnableOption {
				default = false;
				description = "Enable the MacMini server as a syncthing device";
			};
		service.syncthing.devices.galaxy-s10e.enable =
			mkEnableOption {
				default = false;
				description = "Enable the Galaxy-s10e as a syncthing device";
			};
		service.syncthing.devices.PC.enable =
			mkEnableOption {
				default = false;
				description = "Enable the PC as a syncthing device";
			};
		service.syncthing.devices.macbook.enable =
			mkEnableOption {
				default = false;
				description = "Enable the Macbook as a syncthing device";
			};
		service.syncthing.devices.framework.enable =
			mkEnableOption {
				default = false;
				description = "Enable the framework as a syncthing device";
			};

		service.syncthing.folders.secure.enable =
			mkEnableOption {
				default = false;
				description = "Enable the secure folder in syncthing";
			};
		service.syncthing.folders.secure.share =
			mkOption {
				type = with types; listOf str;
				default = [];
				description = "List of devices to share the secure folder with. Devices must be enabled";
			};
		service.syncthing.folders.classes.enable =
			mkEnableOption {
				default = false;
				description = "Enable the classes folder in syncthing";
			};
		service.syncthing.folders.classes.share =
			mkOption {
				type = with types; listOf str;
				default = [];
				description = "List of devices to share the classes folder with. Devices must be enabled";
			};
		service.syncthing.folders.proj.enable =
			mkEnableOption {
				default = false;
				description = "Enable the proj folder in syncthing";
			};
		service.syncthing.folders.proj.share =
			mkOption {
				type = with types; listOf str;
				default = [];
				description = "List of devices to share the proj folder with. Devices must be enabled";
			};
		service.syncthing.folders.wallpapers.enable =
			mkEnableOption {
				default = false;
				description = "Enable the wallpapers folder in syncthing";
			};
		service.syncthing.folders.wallpapers.share =
			mkOption {
				type = with types; listOf str;
				default = [];
				description = "List of devices to share the wallpapers folder with. Devices must be enabled";
			};
	};
	config =
		mkIf config.service.syncthing.enable {
			systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder
			services.syncthing = {
				enable = true;
				systemService = true; # auto launch as system service
				user = config.service.syncthing.user;
				group = config.service.syncthing.group;
				# extraOptions = [ ];
				openDefaultPorts = true; # if running multiple instances, must be false;
				guiAddress = "localhost:8384";
				cert = "${toString ./cert.pem}";
				key = "${toString ./key.pem}";
				dataDir = config.service.syncthing.dataDir;
				configDir = config.service.syncthing.configDir;
				# These make it so that only folders or devices configured here
				# persist. Anything configured on the gui will not
				overrideDevices = true;
				overrideFolders = false;

				relay.enable = false;

				settings = {
					options = {
						limitBandwidthInLan = false;
						globalAnnounceEnabled = false;
						localAnnounceEnabled = true;
						localAnnouncePort = null;
						maxFolderConcurrency = 2;
						relaysEnabled = false;
						urAccepted = -1;
					};
					# configure which devices to connect to
					devices = {
						"MacMini-Server" =
							mkIf config.service.syncthing.devices.macmini-server.enable {
								id = "YEPHB7F-ZVCVOXK-PP4M6NT-C2D2BNH-JYFEW26-2Z7GIJE-ZBYUINV-2K3OAAJ";
								name = "MacMini-server";
								autoAcceptFolders = false;
							};
						"Galaxy-s10e" =
							mkIf config.service.syncthing.devices.galaxy-s10e.enable {
								id = "NYORDT7-6IUBNB6-7DGXYQA-TK2TZLW-YJYDBOK-E3PISCB-PIHPSAA-EQI7VQI";
								name = "Galaxy-s10e";
								autoAcceptFolders = false;
							};
						"PC" =
							mkIf config.service.syncthing.devices.PC.enable {
								id = "2WONTYB-TZI6CPL-ZRPSNNE-UJUEZ7U-MJTIMIB-MEHE7SD-UQ4EKSH-ORQEYAO";
								name = "PC";
								autoAcceptFolders = false;
							};
						"Macbook" =
							mkIf config.service.syncthing.devices.macbook.enable {
								id = "JHDOCOP-XUNBSGU-DS23HBW-F6ICDYQ-DETE6QY-UKODVL3-264LIWY-3GIWMAP";
								name = "Macbook";
								autoAcceptFolders = false;
							};
						"Framework" =
							mkIf config.service.syncthing.devices.framework.enable {
								id = "KSLCF4V-WNXVWF7-5MFHBJC-QUQ43A2-JNNRT63-NW4NEMY-WFCGUVD-OCUOAQL";
								name = "Framework";
								autoAcceptFolders = false;
							};
					};
					# configure folders to sync
					folders =
						mkIf config.service.syncthing.folders.secure.enable {
							"26bfd-pbgoj" = {
								id = "26bfd-pbgoj";
								enable = true;
								label = "secure";
								path = "~/secure";
								type = "sendreceive";
								copyOwnershipFromParent = false;
								devices = config.service.syncthing.folders.secure.share;
								versioning = {
									type = "simple";
									params.keep = 5;
									params.cleanoutDays = 20;
								};
							};
							"9j26s-pweyy" =
								mkIf config.service.syncthing.folders.classes.enable {
									id = "9j26s-pweyy";
									enable = true;
									label = "classes";
									path = "~/classes";
									type = "sendreceive";
									copyOwnershipFromParent = false;
									devices = config.service.syncthing.folders.classes.share;
									versioning = {
										type = "simple";
										params.keep = 5;
										params.cleanoutDays = 20;
									};
								};
							"jwvcx-y7w2m" =
								mkIf config.service.syncthing.folders.proj.enable {
									id = "jwvcx-y7w2m";
									enable = true;
									label = "proj";
									path = "~/proj";
									type = "sendreceive";
									copyOwnershipFromParent = false;
									devices = config.service.syncthing.folders.proj.share;
									versioning = {
										type = "simple";
										params.keep = 5;
										params.cleanoutDays = 20;
									};
								};
							"vjhql-ghx7b" =
								mkIf config.service.syncthing.folders.wallpapers.enable {
									id = "vjhql-ghx7b";
									enable = true;
									label = "wallpapers";
									path = "~/wallpapers";
									type = "sendreceive";
									copyOwnershipFromParent = false;
									devices = config.service.syncthing.folders.wallpapers.share;
									versioning = {
										type = "simple";
									};
								};
						};
				};
			};
		};
}
