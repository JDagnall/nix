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
        types
        ;
    cfg = config.service.media-services.syncthing;
in {
    options.service.media-services.syncthing = {
        enable = mkEnableOption "Enable syncthing config";
        user = mkOption {
            default = "syncthing";
            type = types.str;
            description = ''
                Sets the config user, groups, configDir and dataDir to where you would expect them to be for a normal user of the given name (/home/x)
                Does not create the user, if this is not set, it will default to creating a syncthing user and storing data in /var/lib/syncthing.
                               Could fairly easily have it create the user, but I don't need that right now.
            '';
        };
        dataDir = mkOption {
            type = lib.types.path;
            default =
                if cfg.user == "syncthing"
                then "/var/lib/syncthing"
                else "/home/${cfg.user}";
        };
        gui = {
            enableLogin = mkEnableOption "Enable the login for the syncthin gui requires sops secret syncthing/hashed-gui-password to be set.";
            username = mkOption {
                default = "james";
                type = lib.types.str;
                description = "The username for the login";
            };
            setDefaultRoute = mkEnableOption "Sets the gui address to 0.0.0.0:port so that it can be accessed from outside the device. Also opens the port in the firewall";
        };
        devices = {
            macmini-server.enable = mkEnableOption "Enable the MacMini server as a syncthing device";
            galaxy-s10e.enable = mkEnableOption "Enable the Galaxy-s10e as a syncthing device";
            PC.enable = mkEnableOption "Enable the PC as a syncthing device";
            macbook.enable = mkEnableOption "Enable the Macbook as a syncthing device";
            framework.enable = mkEnableOption "Enable the framework as a syncthing device";
            orion.enable = mkEnableOption "Enable orion as a syncthing device";
        };
        folders = {
            defaultShareDevices = mkOption {
                type = with types; listOf str;
                default = [];
                description = "List of devices to share the folders with as the default. Devices must be enabled";
            };
            secure.enable = mkEnableOption "Enable the secure folder in syncthing";
            secure.share = mkOption {
                type = with types; listOf str;
                default = cfg.folders.defaultShareDevices;
                description = "List of devices to share the secure folder with. Devices must be enabled";
            };
            classes.enable = mkEnableOption "Enable the classes folder in syncthing";
            classes.share = mkOption {
                type = with types; listOf str;
                default = cfg.folders.defaultShareDevices;
                description = "List of devices to share the classes folder with. Devices must be enabled";
            };
            proj.enable = mkEnableOption "Enable the proj folder in syncthing";
            proj.share = mkOption {
                type = with types; listOf str;
                default = cfg.folders.defaultShareDevices;
                description = "List of devices to share the proj folder with. Devices must be enabled";
            };
            wallpapers.enable = mkEnableOption "Enable the wallpapers folder in syncthing";
            wallpapers.share = mkOption {
                type = with types; listOf str;
                default = cfg.folders.defaultShareDevices;
                description = "List of devices to share the wallpapers folder with. Devices must be enabled";
            };
            docs.enable = mkEnableOption "Enable the docs folder in syncthing";
            docs.share = mkOption {
                type = with types; listOf str;
                default = cfg.folders.defaultShareDevices;
                description = "List of devices to share the docs folder with. Devices must be enabled";
            };
        };
    };
    config = let
        port = 8384;
    in
        mkIf cfg.enable {
            assertions = [
                {
                    assertion = config.sops.enable;
                    message = "Sops is required to get the cert / key files and the gui password for syncthing.";
                }
            ];
            service.media-services.services.syncthing = {
                port = port;
                user = cfg.user;
                mkRevProxy = true;
            };
            sops.secrets = let
                host = config.networking.hostName;
                secretSettings = {
                    sopsFile = ../../../secrets/${host}/syncthing.yaml;
                    owner = cfg.user;
                    restartUnits = ["syncthing.service"];
                };
            in
                lib.mkIf config.sops.enable {
                    "syncthing/key" = secretSettings;
                    "syncthing/cert" = secretSettings;
                    "syncthing/hashed-gui-password" = mkIf cfg.gui.enableLogin secretSettings;
                };
            systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder
            services.syncthing = {
                enable = true;
                user = cfg.user;
                dataDir = cfg.dataDir;
                systemService = true; # auto launch as system service
                # extraOptions = [ ];
                openDefaultPorts = true; # if running multiple instances, must be false;
                guiAddress =
                    if cfg.gui.setDefaultRoute
                    then "0.0.0.0:${toString port}"
                    else "localhost:${toString port}";
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
                        "MacMini-Server" = mkIf cfg.devices.macmini-server.enable {
                            id = "YEPHB7F-ZVCVOXK-PP4M6NT-C2D2BNH-JYFEW26-2Z7GIJE-ZBYUINV-2K3OAAJ";
                            addresses = lib.mkIf config.service.tailscale.enable [
                                "tcp://mini:22000"
                            ];
                            name = "MacMini-server";
                            autoAcceptFolders = false;
                        };
                        "Galaxy-s10e" = mkIf cfg.devices.galaxy-s10e.enable {
                            id = "NYORDT7-6IUBNB6-7DGXYQA-TK2TZLW-YJYDBOK-E3PISCB-PIHPSAA-EQI7VQI";
                            addresses = lib.mkIf config.service.tailscale.enable [
                                "tcp://samsung-s10e:22000"
                            ];
                            name = "Galaxy-s10e";
                            autoAcceptFolders = false;
                        };
                        "PC" = mkIf cfg.devices.PC.enable {
                            id = "LUNWAUX-SIKFQ5O-PDYIJW7-3DCCK2A-ZAGF4M2-MR2XTCL-UNNA2O4-CEZLDQX";
                            addresses = lib.mkIf config.service.tailscale.enable [
                                "tcp://pc:22000"
                            ];
                            name = "PC-linux";
                            autoAcceptFolders = false;
                        };
                        "Macbook" = mkIf cfg.devices.macbook.enable {
                            id = "AGENCX4-T4DBKCJ-U4VUN6S-ZE2RBSI-ECBMERW-3OOL5MP-4AEIWFH-GAAN5AV";
                            addresses = lib.mkIf config.service.tailscale.enable [
                                "tcp://book:22000"
                            ];
                            name = "Macbook";
                            autoAcceptFolders = false;
                        };
                        "Framework" = mkIf cfg.devices.framework.enable {
                            id = "KSLCF4V-WNXVWF7-5MFHBJC-QUQ43A2-JNNRT63-NW4NEMY-WFCGUVD-OCUOAQL";
                            addresses = lib.mkIf config.service.tailscale.enable [
                                "tcp://framework:22000"
                            ];
                            name = "Framework";
                            autoAcceptFolders = false;
                        };
                        "Orion" = mkIf cfg.devices.orion.enable {
                            id = "QQCYANM-MSTQWN3-VPYALHR-XXCWM6V-MU37PWP-VSDOY7F-BSWJFDH-Y4JBXQB";
                            addresses = lib.mkIf config.service.tailscale.enable [
                                "tcp://orion:22000"
                            ];
                            name = "Orion";
                            autoAcceptFolders = false;
                        };
                    };
                    # configure folders to sync
                    folders = mkIf cfg.folders.secure.enable {
                        "26bfd-pbgoj" = {
                            id = "26bfd-pbgoj";
                            enable = true;
                            label = "secure";
                            path = "~/secure";
                            type = "sendreceive";
                            copyOwnershipFromParent = false;
                            devices = cfg.folders.secure.share;
                            versioning = {
                                type = "simple";
                                params.keeps = "5";
                                params.cleanoutDays = "20";
                            };
                        };
                        "9j26s-pweyy" = mkIf cfg.folders.classes.enable {
                            id = "9j26s-pweyy";
                            enable = true;
                            label = "classes";
                            path = "~/classes";
                            type = "sendreceive";
                            copyOwnershipFromParent = false;
                            devices = cfg.folders.classes.share;
                            versioning = {
                                type = "simple";
                                params.keeps = "5";
                                params.cleanoutDays = "20";
                            };
                        };
                        "jwvcx-y7w2m" = mkIf cfg.folders.proj.enable {
                            id = "jwvcx-y7w2m";
                            enable = true;
                            label = "proj";
                            path = "~/proj";
                            type = "sendreceive";
                            copyOwnershipFromParent = false;
                            devices = cfg.folders.proj.share;
                            versioning = {
                                type = "simple";
                                params.keeps = "5";
                                params.cleanoutDays = "20";
                            };
                        };
                        "vjhql-ghx7b" = mkIf cfg.folders.wallpapers.enable {
                            id = "vjhql-ghx7b";
                            enable = true;
                            label = "wallpapers";
                            path = "~/wallpapers";
                            type = "sendreceive";
                            copyOwnershipFromParent = false;
                            devices = cfg.folders.wallpapers.share;
                            versioning = {
                                type = "simple";
                            };
                        };
                        "pysjc-vrzgj" = mkIf cfg.folders.wallpapers.enable {
                            id = "pysjc-vrzgj";
                            enable = true;
                            label = "docs";
                            path = "~/docs";
                            type = "sendreceive";
                            copyOwnershipFromParent = false;
                            devices = cfg.folders.docs.share;
                            versioning = {
                                type = "simple";
                            };
                        };
                    };
                };
            };
            networking.firewall.allowedTCPPorts = mkIf cfg.gui.setDefaultRoute [port];
            systemd.services.syncthing-loginmanager = mkIf cfg.gui.enableLogin {
                description = "Syncthing GUI Login Manager";
                # requisite = ["syncthing.service"];
                before = ["syncthing.service" "syncthing-init.service"];
                wantedBy = ["multi-user.target"];

                serviceConfig = {
                    User = config.services.syncthing.user;
                    RemainAfterExit = true;
                    # RuntimeDirectory = "syncthing-init";
                    Type = "oneshot";
                    ExecStart = pkgs.writers.writeBash "add-syncthing-gui-login"
                    ''
                        ${pkgs.syncthing}/bin/syncthing generate --gui-user=${cfg.gui.username} \
                        --gui-password=$(cat ${config.sops.secrets."syncthing/hashed-gui-password".path}) \
                        --home=${config.services.syncthing.configDir} || echo "Failed to set GUI login for syncthing."
                    '';
                };
            };
        };
}
