{
	pkgs,
	lib,
	config,
	...
}: {
	options = {
		gaming.gamescope.enable =
			lib.mkEnableOption {
				description = "Enable gamescope. Optimisations for game windows and processes.";
			};
	};
	config =
		lib.mkIf config.gaming.gamescope.enable {
			programs.gamescope = {
				enable = true;
				capSysNice = true;
				env = {};
				args = [
					"--mangoapp"
					"--expose-wayland"
				];
			};
		};
}
