{
	# pkgs,
	lib,
	config,
	...
}: {
	options = {
		evremap.enable =
			lib.mkEnableOption {
				description = "Enable evremap, a key remapper that works in wayland. By Wez.";
			};
		evremap.profile =
			lib.mkOption {
				type = lib.types.nullOr (lib.types.enum ["logi-k855"]);
				default = null;
				description = "The keyboard you are using / the profile you want to use";
			};
	};
	config = let
		logi_k855 = {
			phys = "usb-0000:16:00.0-6/input0";
			device_name = "Logitech USB Receiver";
			remap = [
				{
					input = ["KEY_LEFTMETA"];
					output = ["KEY_LEFT_ALT"];
				}
				{
					input = ["KEY_LEFT_ALT"];
					output = ["KEY_LEFTMETA"];
				}
			];
		};
	in
		lib.mkIf config.evremap.enable {
			services.evremap = {
				enable = true;
				settings =
					if config.evremap.profile == "logi-k855"
					then logi_k855
					else null;
			};
		};
}
