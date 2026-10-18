{
    self,
    lib,
    inputs,
    ...
}: let
    deviceType = with lib.types;
        submodule ({name, ...}: {
            # freeformType = attrs anything;
            options = {
                name = lib.mkOption {
                    type = str;
                    default = name;
                };
                id = lib.mkOption {
                    type = str;
                    description = "The unique syncthing device identifer";
                };
                connectOverTailscale = lib.mkEnableOption "Connect to this device";
                tailscaleHostName = lib.mkOption {
                    type = nullOr str;
                    description = "The hostname to reach this device with over the tailnet.";
                    default = null;
                };
            };
        });
    mkDevice = device: tailscaleEnabled:
        lib.nameValuePair device.name {
            id = device.id;
            name = device.name;
            autoAcceptFolders = false;
            addresses = lib.optional device.connectOverTailscale "tcp://${device.tailscaleHostName}:22000";
        };
    folderType = with lib.types;
        submodule (
            {name, ...}: {
                # freeformType = attrs anything;
                options = {
                    name = lib.mkOption {
                        type = str;
                        default = name;
                    };
                    id = lib.mkOption {
                        type = str;
                        description = "The unique syncthing device identifer";
                    };
                    path = lib.mkOption {
                        type = str;
                        default = "~/${name}";
                    };
                    type = lib.mkOption {
                        type = enum ["sendreceive" "sendonly" "receiveonly"];
                        default = "sendreceive";
                    };
                    label = lib.mkOption {
                        type = str;
                        default = name;
                    };
                    versioning = lib.mkOption {
                        type = attrs;
                        default = {
                            type = "simple";
                            params.keeps = "5";
                            params.cleanoutDays = "20";
                        };
                    };
                    devices = lib.mkOption {
                        type = listOf str;
                        default = [];
                        description = "Devices to share this folder with.";
                    };
                };
            }
        );
    mkFolder = folder:
        lib.nameValuePair folder.id {
            name = folder.name;
            id = folder.id;
            versioning = folder.versioning;
            label = folder.label;
            path = folder.path;
            enable = true;
            devices = folder.devices;
            type = folder.type;
            copyOwnershipFromParent = false;
        };
    commonServiceConfig = {
        enable = true;
        systemService = true; # auto launch as system service
        # extraOptions = [ ];
        openDefaultPorts = true; # if running multiple instances, must be false;
        # These make it so that only folders or devices configured here
        # persist. Anything configured on the gui will not persist.
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
        };
    };
in {
    # this is specifically a "client" user syncthing service. It does not forward
    # its gui at all and thus doesn't need to configure authentication for it.
    flake.modules.home.syncthing = {
        osConfig,
        config,
        ...
    }: let
        cfg = config.my.services.syncthing;
        tailscaleEnabled = osConfig.my.services.tailscale.enabled;
    in {
        imports = with self.modules.home; [sops];
        options.my.services.syncthing = {
            devices = lib.mkOption {
                type = with lib.types; attrsOf deviceType;
                default = {};
            };
            folders = lib.mkOption {
                type = with lib.types; attrsOf folderType;
                default = {};
            };
        };
        config = {
            assertions = [
                {
                    assertion = osConfig.services.syncthing.enable == false;
                    message = "Cannot run a system user syncthing instance, and a user instance. The ports will interfere.";
                }
            ];
            sops.secrets = let
                host = config.networking.hostName;
                secretSettings = {
                    sopsFile = "${inputs.secrets}/${host}/syncthing.yaml";
                    restartUnits = ["syncthing.service"];
                };
            in {
                "syncthing/key" = secretSettings;
                "syncthing/cert" = secretSettings;
            };
            systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder
            services.syncthing =
                {
                    tray.enable = true;
                    guiAddress = "localhost:8384";
                    # guiCredentials = {
                    #     username = config.home.username;
                    #     passwordFile = config.sops.secrets."syncthing.password".path;
                    # };
                    cert = "${config.sops.secrets."syncthing/cert".path}";
                    key = "${config.sops.secrets."syncthing/key".path}";
                    settings = {
                        devices = builtins.mapAttrs (_: device: (mkDevice device tailscaleEnabled)) cfg.devices;
                        folders = builtins.mapAttrs (_: folder: (mkFolder folder)) cfg.folders;
                    };
                }
                // commonServiceConfig;
        };
    };
    # run as system user
    flake.modules.nixos.syncthing = {config, ...}: let
        cfg = config.my.services.syncthing;
        tailscaleEnabled = config.my.services.tailscale.enabled;
    in {
        imports = with self.modules.nixos; [sops];
        options.my.services.syncthing = {
            devices = lib.mkOption {
                type = with lib.types; attrsOf deviceType {};
            };
            folders = lib.mkOption {
                type = with lib.types; attrsOf folderType {};
            };
        };
        config = {
            sops.secrets = let
                host = config.networking.hostName;
                secretSettings = {
                    sopsFile = "${inputs.secrets}/${host}/syncthing.yaml";
                    restartUnits = ["syncthing.service"];
                };
            in {
                "syncthing/key" = secretSettings;
                "syncthing/cert" = secretSettings;
            };
            systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder
            services.syncthing =
                {
                    cert = "${config.sops.secrets."syncthing/cert".path}";
                    key = "${config.sops.secrets."syncthing/key".path}";
                    settings = {
                        devices = builtins.mapAttrs (_: device: (mkDevice device tailscaleEnabled)) cfg.devices;
                        folders = builtins.mapAttrs (_: folder: (mkFolder folder)) cfg.folders;
                    };
                }
                // commonServiceConfig;
        };
    };
}
