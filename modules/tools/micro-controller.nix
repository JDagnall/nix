{
	pkgs,
	lib,
	config,
	...
}: {
	options = {
		tools.micro-controller.platformio.enableUdev = lib.mkEnableOption "Enable udev rules for platformio";
	};
	config = {
		services.udev.packages =
			lib.mkIf config.tools.micro-controller.platformio.enableUdev [
				pkgs.platformio-core.udev
				pkgs.openocd
			];
	};
}
