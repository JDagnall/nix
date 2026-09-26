{
    lib,
    config,
    ...
}: let
    mediaCfg = config.service.media-services;
    cfg = config.service.media-services.immich;
in {
    options = {
        service.media-services.immich = {
            enable = lib.mkEnableOption "Enable immich";
            enableHarwareAcceleration = lib.mkEnableOption "Enable GPU acceleration." // {default = true;};
            dataDir = lib.mkOption {
                type = lib.types.path;
                default = "/var/lib/immich";
            };
        };
    };
    config = let
        gpuDev =
            if (cfg.enableHarwareAcceleration && config.nvidia.enable)
            then ["/dev/nvidia0"]
            # for most other GPU's
            else if cfg.enableHarwareAcceleration
            then ["/dev/dri/renderD128"]
            else [];
    in
        lib.mkIf (mediaCfg.enable && cfg.enable) {
            service.media-services.services.immich = {
                port = 2283;
                user = "immich";
                inMediaGroup = false;
                mkRevProxy = true;
            };
            sops.secrets = let
                host = config.networking.hostName;
                secretCfg = {
                    sopsFile = ../../../secrets/${host}/immich.yaml;
                };
            in
                lib.mkIf config.sops.enable {
                    "immich/db_pass" = secretCfg;
                };
            sops.templates."immich-env" = let
                sops-placeholder = config.sops.placeholder;
            in
                lib.mkIf config.sops.enable {
                    content = ''
                        DB_PASSWORD=${sops-placeholder."immich/db_pass"}
                    '';
                };

            # nvidia may need these extra devices to work
            systemd.services.jellyfin.serviceConfig.DeviceAllow = lib.optionals (cfg.enableHarwareAcceleration && config.nvidia.enable) [
                "/dev/nvidiactl rw"
                "/dev/nvidia-modeset rw"
                "/dev/nvidia-uvm rw"
            ];
            services.immich = let
                serviceCfg = config.service.media-services.services.immich;
            in {
                enable = true;
                user = serviceCfg.user;
                # group = ;
                host = "localhost"; # rev proxy
                openFirewall = false;
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
                accelerationDevices = gpuDev;
                secretsFile = config.sops.templates."immich-env".path;
                settings = {
                    newVersionCheck.enable = false;
                    # server.externalDomain = ;
                };
                environment = {};
            };
        };
}
