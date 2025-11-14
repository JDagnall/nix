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
			phys = "usb-0000:02:00.0-1/input0";
			device_name = "Logitech USB Receiver";
			remap = [
				{
					input = ["KEY_LEFTMETA"];
					output = ["KEY_LEFTALT"];
				}
				{
					input = ["KEY_LEFTALT"];
					output = ["KEY_LEFTMETA"];
				}
				{
					input = ["KEY_CAPSLOCK"];
					output = ["KEY_ESC"];
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
