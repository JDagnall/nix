{
	# pkgs,
	lib,
	config,
	osConfig,
	...
}: {
	options = {
		gaming.lutris.enable =
			lib.mkEnableOption {
				description = "Enable lutris, a launcher for games.";
			};
	};
	config =
		lib.mkIf config.gaming.lutris.enable {
			programs.lutris = {
				enable = true;
				# defaultWinePackage = ;
				protonPackages = [];
				winePackages = [];
				runners = {
					# eg = {
					# 	package = pkg;
					# 	settings = {
					# 		system = {};
					# 	};
					#                 runner = {};
					# };
				};
				steamPackage = osConfig.programs.steam.package;
			};
		};
}
