{
	# pkgs,
	lib,
	config,
	...
}: let
	inherit (lib) mkIf mkEnableOption;
in {
	options = {
		nvidia.enable =
			mkEnableOption {
				description = ''
					Enable the required setting for using an NVIDIA GPU with with various software,
					expect this to grow with options for specific software
				'';
			};
	};
	config =
		mkIf config.nvidia.enable {
			hardware.nvidia = {
				enabled = true;
				# Most wayland compositors need this
				modesetting.enable = true;

				# not using this at the moment, if stuff crashed waking up from sleep, try to use it
				# powerManagement.enable = true;

				# open source kernel module, still in development, might be worth a try
				# open = true;

				# graphical settings menu
				nvidiaSettings = true;

				# could be stable, production, beta or latest
				package = config.boot.kernelPackages.nvidiaPackages.stable;
			};
			services.xserver.videoDrivers = ["nvidia"];
		};
}
