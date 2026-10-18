{
    self,
    lib,
    inputs,
    ...
}: {
    flake.modules.nixos.immich = {config, ...}: let
        cfg = config.my.servers.immich;
    in {
        imports = with self.modules.nixos; [servers gpu sops];
        options = {
            my.servers.immich = {
                enableHarwareAcceleration = lib.mkEnableOption "Enable GPU acceleration." // {default = config.my.hardware.gpu.type != null;};
                dataDir = lib.mkOption {
                    type = lib.types.path;
                    default = "/var/lib/immich";
                };
            };
        };
        config = let
            gpuDev = config.my.hardware.gpu.devPath;
            accelDevs =
                if gpuDev != null
                then [gpuDev]
                else [];
        in {
            my.servers.servers.immich = {
                port = 2283;
                user = "immich";
                group = "immich";
                mkRevProxy = true;
            };
            sops.secrets = let
                hostName = config.networking.hostName;
                secretCfg = {
                    sopsFile = "${inputs.secrets}/${hostName}/immich.yaml";
                };
            in {
                "immich/db_pass" = secretCfg;
            };
            sops.templates."immich-env" = let
                sops-placeholder = config.sops.placeholder;
            in {
                content = ''
                    DB_PASSWORD=${sops-placeholder."immich/db_pass"}
                '';
            };

            # nvidia may need these extra devices to work
            systemd.services.jellyfin.serviceConfig.DeviceAllow = lib.optionals (cfg.enableHarwareAcceleration && config.my.hardware.gpu.type == "nvidia") [
                "/dev/nvidiactl rw"
                "/dev/nvidia-modeset rw"
                "/dev/nvidia-uvm rw"
            ];
            services.immich = let
                serverCfg = config.my.servers.servers.immich;
            in {
                enable = true;
                user = serverCfg.user;
                group = serverCfg.group;
                host = serverCfg.host;
                openFirewall = serverCfg.openFirewall;
                mediaLocation = cfg.dataDir;
                database = {
                    enable = true; # ?
                    createDB = true;
                    # host = ; # defauts are fine, its just local
                    # name = ;
                    # port = ;
                    # user = ;
                };
                redis = {
                    enable = true;
                    # host = ; # defauts are fine, its just local
                    # port = ;
                };
                machine-learning = {
                    enable = true; # dont think I really need this
                    environment = {};
                };
                accelerationDevices = accelDevs;
                secretsFile = config.sops.templates."immich-env".path;
                settings = {
                    newVersionCheck.enable = false;
                    # server.externalDomain = ;
                };
                environment = {};
            };
        };
    };
}
