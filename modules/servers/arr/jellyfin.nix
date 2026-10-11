{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.jellyfin = {
        pkgs,
        config,
        ...
    }: let
        arrCfg = config.my.servers.arr;
        cfg = config.my.servers.arr.jellyfin;
        gpuCfg = config.my.hardware.gpu;
        serverCfg = config.my.servers.servers.jellyfin;
    in {
        imports = with self.modules.nixos; [servers arr gpu]; # interface for knowing what / if a gpu is configured.
        options.my = {
            servers.arr.jellyfin = {
                enableGpuTranscoding = lib.mkEnableOption "Enable hardware accelerated transcoding." // {default = gpuCfg.type != null;};
            };
        };
        config = {
            assertions =
                []
                ++ lib.optional cfg.enableGpuTranscoding {
                    assertion = gpuCfg.type != null && config.hardware.graphics.enable;
                    message = ''
                        GPU transcoding requires `hardware.graphics.enable` to load GPU drivers
                        and the type of gpu should be specified according to flake.modules.nixos.gpu.
                    '';
                };
            my.servers.servers.jellyfin = {
                host = "0.0.0.0";
                port = 8096;
                openFirewall = true; # tv on lan
                user = "jellyfin";
                group = arrCfg.group.name;
                mkRevProxy = true;
            };
            environment.systemPackages = with pkgs; [
                jellyfin-web
                jellyfin-ffmpeg # should be used by the service?
            ];
            # nvidia needs these extra devices to work
            systemd.services.jellyfin.serviceConfig.DeviceAllow = lib.optionals (cfg.enableGpuTranscoding && gpuCfg.type == "nvidia") [
                "/dev/nvidiactl rw"
                "/dev/nvidia-modeset rw"
                "/dev/nvidia-uvm rw"
            ];
            # permissions for using the gpu
            users.users.${serverCfg.user}.extraGroups = lib.optionals cfg.enableGpuTranscoding ["render" "video"];
            services.jellyfin = {
                enable = true;
                openFirewall = serverCfg.openFirewall; # tv on lan
                user = serverCfg.user;
                group = serverCfg.group.name;
                # cacheDir = "/var/lib/jellyfin";
                # logDir = "/var/lib/jellyfin/log";
                hardwareAcceleration = {
                    # currently only using on an nvidia
                    enable =
                        cfg.enableGpuTranscoding;
                    # currently only using this on an nvidia card
                    # this might be a little device specific and maybe should be able to be overridden
                    type =
                        if gpuCfg.type == "nvidia"
                        then "nvenc"
                        else if gpuCfg.type == "amd"
                        then "amf"
                        else "none";
                    # not sure if this is necesary
                    device =
                        if gpuCfg.type != null
                        then gpuCfg.device
                        else null;
                };
                transcoding = {
                    enableHardwareEncoding = cfg.enableGpuTranscoding;
                    enableToneMapping = cfg.enableGpuTranscoding;
                    hardwareDecodingCodecs.h264 = true;
                };
            };
            # TODO: use the arr option umask here?
            systemd.services.jellyfin.serviceConfig.Umask = lib.mkForce "0007";
        };
    };
}
