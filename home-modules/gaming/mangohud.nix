{
	# pkgs,
	lib,
	config,
	...
}: {
	options = {
		gaming.mangohud.enable =
			lib.mkEnableOption {
				description = "Enable mangohud config. Already installed with steam as a dependency.";
			};
	};
	config =
		lib.mkIf config.gaming.mangohud.enable {
			programs.mangohud = {
				enable = true;
				enableSessionWide = true;
				settings = {
					legacy_layout = 2;
				};
				settingsPerApplication = {};
			};
			stylix.targets.mangohud.enable = config.stylix.enableHomeConfig;
		};
}
