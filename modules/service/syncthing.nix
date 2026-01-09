{
	pkgs,
	lib,
	config,
	...
}: let
	inherit
		(lib)
		mkIf
		mkEnableOption
		mkOption
		optionalAttrs
		types
		;
in {
	options.service.syncthing = {
		enable = mkEnableOption "Enable syncthing config";
		runAsUser =
			mkOption {
				default = null;
				type = with types; nullOr str;
				description = ''
					Sets the config user, groups, configDir and dataDir to where you would expect them to be for a normal user of the given name (/home/x)
					Does not create the user, if this is not set, it will default to creating a syncthing user and storing data in /var/lib/syncthing.
					               Could fairly easily have it create the user, but I don't need that right now.
				'';
			};
		gui = {
			enableLogin = mkEnableOption "Enable the login for the syncthin gui requires sops secret syncthing/hashed-gui-password to be set.";
			username =
				mkOption {
					default = "james";
					type = lib.types.str;
					description = "The username for the login";
				};
			setDefaultRoute = mkEnableOption "Sets the gui address to 0.0.0.0:port so that it can be accessed from outside the device. Also opens the port in the firewall";
		};
		devices = {
			macmini-server.enable = mkEnableOption "Enable the MacMini server as a syncthing device";
			galaxy-s10e.enable = mkEnableOption "Enable the Galaxy-s10e as a syncthing device";
			PC-windows.enable = mkEnableOption "Enable the PC-windows install as a syncthing device";
			PC.enable = mkEnableOption "Enable the PC as a syncthing device";
			macbook.enable = mkEnableOption "Enable the Macbook as a syncthing device";
			framework.enable = mkEnableOption "Enable the framework as a syncthing device";
		};
		folders = {
			defaultShareDevices =
				mkOption {
					type = with types; listOf str;
					default = [];
					description = "List of devices to share the folders with as the default. Devices must be enabled";
				};
			secure.enable = mkEnableOption "Enable the secure folder in syncthing";
			secure.share =
				mkOption {
					type = with types; listOf str;
					default = config.service.syncthing.folders.defaultShareDevices;
					description = "List of devices to share the secure folder with. Devices must be enabled";
				};
			classes.enable = mkEnableOption "Enable the classes folder in syncthing";
			classes.share =
				mkOption {
					type = with types; listOf str;
					default = config.service.syncthing.folders.defaultShareDevices;
					description = "List of devices to share the classes folder with. Devices must be enabled";
				};
			proj.enable = mkEnableOption "Enable the proj folder in syncthing";
			proj.share =
				mkOption {
					type = with types; listOf str;
					default = config.service.syncthing.folders.defaultShareDevices;
					description = "List of devices to share the proj folder with. Devices must be enabled";
				};
			wallpapers.enable = mkEnableOption "Enable the wallpapers folder in syncthing";
			wallpapers.share =
				mkOption {
					type = with types; listOf str;
					default = config.service.syncthing.folders.defaultShareDevices;
					description = "List of devices to share the wallpapers folder with. Devices must be enabled";
				};
		};
	};
	config =
		mkIf config.service.syncthing.enable {
			assertions = [
				{
					assertion = config.sops.enable;
					message = "Sops is required to get the cert / key files and the gui password for syncthing.";
				}
			];
			sops.secrets = let
				host = config.networking.hostName;
			in
				lib.mkIf config.sops.enable {
					"syncthing/key" = {
						sopsFile = ../../secrets/${host}/syncthing.yaml;
						owner = config.services.syncthing.user;
						restartUnits = ["syncthing.service"];
					};
					"syncthing/cert" = {
						sopsFile = ../../secrets/${host}/syncthing.yaml;
						owner = config.services.syncthing.user;
						restartUnits = ["syncthing.service"];
					};
					"syncthing/hashed-gui-password" =
						mkIf config.service.syncthing.gui.enableLogin {
							sopsFile = ../../secrets/${host}/syncthing.yaml;
							owner = config.services.syncthing.user;
							restartUnits = ["syncthing.service"];
						};
				};
			systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder
			services.syncthing =
				{
					enable = true;
					systemService = true; # auto launch as system service
					# extraOptions = [ ];
					openDefaultPorts = true; # if running multiple instances, must be false;
					guiAddress =
						if config.service.syncthing.gui.setDefaultRoute
						then "0.0.0.0:8384"
						else "localhost:8384";
					cert = "${config.sops.secrets."syncthing/cert".path}";
					key = "${config.sops.secrets."syncthing/key".path}";
					# These make it so that only folders or devices configured here
					# persist. Anything configured on the gui will not
					overrideDevices = true;
					overrideFolders = true;

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
							"PC-windows" =
								mkIf config.service.syncthing.devices.PC-windows.enable {
									id = "2WONTYB-TZI6CPL-ZRPSNNE-UJUEZ7U-MJTIMIB-MEHE7SD-UQ4EKSH-ORQEYAO";
									name = "PC-windows";
									autoAcceptFolders = false;
								};
							"PC" =
								mkIf config.service.syncthing.devices.PC.enable {
									id = "TLTL7NP-L3LLF6M-OZBLULU-42YS7GP-P5OU2K3-KUSCVIU-A4232YP-UVQB5QR";
									name = "PC-linux";
									autoAcceptFolders = false;
								};
							"Macbook" =
								mkIf config.service.syncthing.devices.macbook.enable {
									id = "AGENCX4-T4DBKCJ-U4VUN6S-ZE2RBSI-ECBMERW-3OOL5MP-4AEIWFH-GAAN5AV";
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
										params.keeps = "5";
										params.cleanoutDays = "20";
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
											params.keeps = "5";
											params.cleanoutDays = "20";
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
											params.keeps = "5";
											params.cleanoutDays = "20";
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
				}
				// optionalAttrs (config.service.syncthing.runAsUser != null) {
					user = config.service.syncthing.runAsUser;
					group = config.service.syncthing.runAsUser;
					dataDir = "/home/${config.service.syncthing.runAsUser}";
					configDir = "/home/${config.service.syncthing.runAsUser}/.config/syncthing";
				};
			networking.firewall.allowedTCPPorts = mkIf config.service.syncthing.gui.setDefaultRoute [8384];
			systemd.services.syncthing-loginmanager =
				mkIf config.service.syncthing.gui.enableLogin {
					description = "Syncthing GUI Login Manager";
					# requisite = ["syncthing.service"];
					before = ["syncthing.service" "syncthing-init.service"];
					wantedBy = ["multi-user.target"];

					serviceConfig = {
						User = config.services.syncthing.user;
						RemainAfterExit = true;
						# RuntimeDirectory = "syncthing-init";
						Type = "oneshot";
						ExecStart =
							pkgs.writers.writeBash "add-syncthing-gui-login"
							''
								${pkgs.syncthing}/bin/syncthing generate --gui-user=${config.service.syncthing.gui.username} \
								--gui-password=$(cat ${config.sops.secrets."syncthing/hashed-gui-password".path}) \
								                        --config=${config.services.syncthing.configDir} || echo "Failed to set GUI login for syncthing."
							'';
					};
				};
		};
}
