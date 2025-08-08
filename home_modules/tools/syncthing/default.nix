{ lib, config, ... }:
let
    inherit (lib)
        mkIf
        mkEnableOption
        mkOption
        types
        ;
in
{
    options = {
        tools.syncthing.enable = mkEnableOption {
            default = false;
            description = "Enable syncthing config";
        };
        tools.syncthing.devices.macmini-server.enable = mkEnableOption {
            default = false;
            description = "Enable the MacMini server as a syncthing device";
        };
        tools.syncthing.devices.galaxy-s10e.enable = mkEnableOption {
            default = false;
            description = "Enable the Galaxy-s10e as a syncthing device";
        };
        tools.syncthing.devices.PC.enable = mkEnableOption {
            default = false;
            description = "Enable the PC as a syncthing device";
        };
        tools.syncthing.devices.macbook.enable = mkEnableOption {
            default = false;
            description = "Enable the Macbook as a syncthing device";
        };
        tools.syncthing.devices.framework.enable = mkEnableOption {
            default = false;
            description = "Enable the framework as a syncthing device";
        };

        tools.syncthing.folders.secure.enable = mkEnableOption {
            default = false;
            description = "Enable the secure folder in syncthing";
        };
        tools.syncthing.folders.secure.share = mkOption {
            type = with types; listOf str;
            default = [ ];
            description = "List of devices to share the secure folder with. Devices must be enabled";
        };
        tools.syncthing.folders.classes.enable = mkEnableOption {
            default = false;
            description = "Enable the classes folder in syncthing";
        };
        tools.syncthing.folders.classes.share = mkOption {
            type = with types; listOf str;
            default = [ ];
            description = "List of devices to share the classes folder with. Devices must be enabled";
        };
        tools.syncthing.folders.proj.enable = mkEnableOption {
            default = false;
            description = "Enable the proj folder in syncthing";
        };
        tools.syncthing.folders.proj.share = mkOption {
            type = with types; listOf str;
            default = [ ];
            description = "List of devices to share the proj folder with. Devices must be enabled";
        };
        tools.syncthing.folders.wallpapers.enable = mkEnableOption {
            default = false;
            description = "Enable the wallpapers folder in syncthing";
        };
        tools.syncthing.folders.wallpapers.share = mkOption {
            type = with types; listOf str;
            default = [ ];
            description = "List of devices to share the wallpapers folder with. Devices must be enabled";
        };
    };
    config = mkIf config.tools.syncthing.enable {
        services.syncthing = {
            enable = true;
            tray = true; # syncthing tray
            extraOptions = [ ];
            guiAddress = "localhost:8384"; # try another address like syncthing.localhost
            cert = "./cert.pem"; # add path to cert file once generated
            key = "./key.pem"; # ^
            # These make it so that only folders or devices configured here
            # persist. Anything configured on the gui will not
            overrideDevices = true;
            overrideFolders = true;

            settings.options = {
                limitBandwidthInLan = false;
                localAnnounceEnable = false;
                localAnnouncePort = null;
                maxFolderConcurrency = 2;
                relaysEnabled = false;
                urAccepted = -1;
            };

            # configure which devices to connect to
            settings.devices = {
                macmini-server = mkIf config.tools.syncthing.devices.macmini-server.enable {
                    id = "YEPHB7F-ZVCVOXK-PP4M6NT-C2D2BNH-JYFEW26-2Z7GIJE-ZBYUINV-2K3OAAJ";
                    name = "MacMini-server";
                    autoAcceptFolders = false;
                };

                galaxy-s10e = mkIf config.tools.syncthing.devices.galaxy-s10e.enable {
                    id = "NYORDT7-6IUBNB6-7DGXYQA-TK2TZLW-YJYDBOK-E3PISCB-PIHPSAA-EQI7VQI";
                    name = "Galaxy-s10e";
                    autoAcceptFolders = false;
                };
                PC = mkIf config.tools.syncthing.devices.PC.enable {
                    id = "2WONTYB-TZI6CPL-ZRPSNNE-UJUEZ7U-MJTIMIB-MEHE7SD-UQ4EKSH-ORQEYAO";
                    name = "PC";
                    autoAcceptFolders = false;
                };
                macbook = mkIf config.tools.syncthing.devices.macbook.enable {
                    id = "JHDOCOP-XUNBSGU-DS23HBW-F6ICDYQ-DETE6QY-UKODVL3-264LIWY-3GIWMAP";
                    name = "Macbook";
                    autoAcceptFolders = false;
                };
                framework = mkIf config.tools.syncthing.devices.framework.enable {
                    id = "UPAHMLX-ZHYHBU7-BBYPAAE-UU3TUIL-ZRYW4OS-DHOYKRP-IOLWKIK-HPF7SQF";
                    name = "Framework";
                    autoAcceptFolders = false;
                };
            };

            settings.folders = {
                secure = mkIf config.tools.syncthing.folders.secure.enable {
                    id = "26bfd-pbgoj";
                    name = "secure";
                    label = "secure";
                    path = "~/secure";
                    type = "sendreceive";
                    copyOwnershipFromParent = false;
                    devices = config.tools.syncthing.folders.secure.share;
                    versioning = {
                        type = "simple";
                        params.keep = 5;
                        params.cleanoutDays = 20;
                    };
                };
                classes = mkIf config.tools.syncthing.folders.classes.enable {
                    id = "9j26s-pweyy";
                    name = "classes";
                    label = "classes";
                    path = "~/classes";
                    type = "sendreceive";
                    copyOwnershipFromParent = false;
                    devices = config.tools.syncthing.folders.classes.share;
                    versioning = {
                        type = "simple";
                        params.keep = 5;
                        params.cleanoutDays = 20;
                    };
                };
                proj = mkIf config.tools.syncthing.folders.proj.enable {
                    id = "jwvcx-y7w2m";
                    name = "proj";
                    label = "proj";
                    path = "~/proj";
                    type = "sendreceive";
                    copyOwnershipFromParent = false;
                    devices = config.tools.syncthing.folders.proj.share;
                    versioning = {
                        type = "simple";
                        params.keep = 5;
                        params.cleanoutDays = 20;
                    };
                };
                wallpapers = mkIf config.tools.syncthing.folders.wallpapers.enable {
                    id = "vjhql-ghx7b";
                    name = "wallpapers";
                    label = "wallpapers";
                    path = "~/wallpapers";
                    type = "sendreceive";
                    copyOwnershipFromParent = false;
                    devices = config.tools.syncthing.folders.wallpapers.share;
                    versioning = {
                        type = "simple";
                        params.keep = 5;
                        params.cleanoutDays = 20;
                    };
                };
            };
        };
    };
}
