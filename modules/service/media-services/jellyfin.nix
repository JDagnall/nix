{
    pkgs,
    lib,
    config,
    ...
}: let
    cfg = config.service.media-services;
in {
    options = {
        service.media-services.jellyfin = {
            enable = lib.mkEnableOption "Enable jellyfin server config.";
            enableGpuTranscoding = lib.mkEnableOption "Enable hardware accelerated transcoding.";
            trancodingGpuPath = lib.mkOption {
                default =
                    if (cfg.jellyfin.enableGpuTranscoding && config.nvidia.enable)
                    then "/dev/nvidia0"
                    # for most other GPU's
                    else if cfg.jellyfin.enableGpuTranscoding
                    then "/dev/dri/renderD128"
                    else null;
                type = lib.types.nullOr lib.types.str;
                description = "The path to the gpu device, defaults to the normal path for simple setups.";
            };
        };
    };
    config = lib.mkIf (cfg.enable && cfg.jellyfin.enable) {
        assertions =
            []
            ++ lib.optional cfg.jellyfin.enableGpuTranscoding {
                assertion = config.hardware.graphics.enable;
                message = "GPU transcoding requires `hardware.graphics.enable` to load GPU drivers";
            };
        environment.systemPackages = with pkgs; [
            jellyfin-web
            jellyfin-ffmpeg # should be used by the service?
        ];
        # nvidia needs these extra devices to work
        systemd.services.jellyfin.serviceConfig.DeviceAllow = lib.optionals (cfg.jellyfin.enableGpuTranscoding && config.nvidia.enable) [
            "/dev/nvidiactl rw"
            "/dev/nvidia-modeset rw"
            "/dev/nvidia-uvm rw"
        ];
        # permissions for using the gpu
        users.users.${config.services.jellyfin.user}.extraGroups = lib.optionals cfg.jellyfin.enableGpuTranscoding ["render" "video"];
        services.jellyfin = {
            enable = true;
            openFirewall = true;
            user = "jellyfin";
            group = cfg.group.name;
            # cacheDir = "/var/lib/jellyfin";
            # logDir = "/var/lib/jellyfin/log";
            hardwareAcceleration = {
                # currently only using on an nvidia
                enable =
                    cfg.jellyfin.enableGpuTranscoding;
                # currently only using this on an nvidia card
                type =
                    if config.nvidia.enable
                    then "nvenc"
                    else "none";
                # not sure if this is necesary
                device = cfg.jellyfin.trancodingGpuPath;
            };
            transcoding = {
                enableHardwareEncoding = cfg.jellyfin.enableGpuTranscoding;
                enableToneMapping = cfg.jellyfin.enableGpuTranscoding;
                hardwareDecodingCodecs.h264 = true;
            };
        };
        systemd.services.jellyfin.serviceConfig.Umask = lib.mkForce "0007";
    };
}
