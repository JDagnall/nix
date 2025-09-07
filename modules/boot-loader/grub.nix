{
	lib,
	config,
	...
}: {
	options = {
		boot-loader.grub.enable =
			lib.mkEnableOption {
				default = false;
				description = "Enable grub boot loader";
			};
	};
	config =
		lib.mkIf config.boot-loader.grub.enable {
			boot.loader.grub = {
				enable = true;
				device = "nodev";
				efiSupport = true;
				useOSProber = false;
				fsIdentifier = "label";
				extraEntries = ''
					menuentry "Reboot" {
					    reboot
					}
					menuentry "Poweroff" {
					    halt
					}
				'';
			};
			boot.loader.efi.canTouchEfiVariables = true;
			boot.loader.efi.efiSysMountPoint = "/boot";

			stylix.targets.grub =
				lib.mkIf config.stylix.enableConfig {
					enable = true;
					useWallpaper = true;
				};
		};
}
