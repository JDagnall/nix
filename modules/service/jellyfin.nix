{
	pkgs,
	lib,
	config,
	...
}: {
	options = {
		service.jellyfin = {
			enable = lib.mkEnableOption "Enable jellyfin server config.";
			enableGpuTranscoding = lib.mkEnableOption "Enable hardware accelerated transcoding.";
			trancodingGpuPath =
				lib.mkOption {
					default =
						if config.service.jellyfin.enableGpuTranscoding
						then "/dev/fb0"
						else null;
					type = lib.types.nullOr lib.types.str;
					description = "The path to the gpu device, defaults to the normal path for simple setups.";
				};
		};
	};
	config =
		lib.mkIf config.service.jellyfin.enable {
			environment.systemPackages = with pkgs; [
				jellyfin-web
				jellyfin-ffmpeg # should be used by the service?
			];
			services.jellyfin = {
				enable = true;
				openFirewall = true;
				user = "jellyfin";
				group = "jellyfin";
				# cacheDir = "/var/lib/jellyfin";
				# logDir = "/var/lib/jellyfin/log";
				hardwareAcceleration = {
					# currently only using on an nvidia
					enable =
						config.service.jellyfin.enableGpuTranscoding;
					# currently only using this on an nvidia card
					type =
						if config.nvidia.enable
						then "nvenc"
						else "none";
					# not sure if this is necesary
					device = config.service.jellyfin.trancodingGpuPath;
				};
				transcoding = {
					enableHardwareEncoding = config.service.jellyfin.enableGpuTranscoding;
					enableToneMapping = config.service.jellyfin.enableGpuTranscoding;
					hardwareDecodingCodecs.h264 = true;
				};
			};
		};
}
