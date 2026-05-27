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
                    if cfg.jellyfin.enableGpuTranscoding
                    then "/dev/fb0"
                    else null;
                type = lib.types.nullOr lib.types.str;
                description = "The path to the gpu device, defaults to the normal path for simple setups.";
            };
        };
    };
    config = lib.mkIf (cfg.enable && cfg.jellyfin.enable) {
        environment.systemPackages = with pkgs; [
            jellyfin-web
            jellyfin-ffmpeg # should be used by the service?
        ];
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
    };
}
