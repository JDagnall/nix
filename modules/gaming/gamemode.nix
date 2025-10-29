{
	pkgs,
	lib,
	config,
	...
}: {
	options = {
		gaming.gamemode.enable =
			lib.mkEnableOption {
				description = "Enable gamemode. GPU optimisations for games among other things.";
			};
	};
	config =
		lib.mkIf config.gaming.gamemode.enable {
			programs.gamemode = {
				enable = true;
				enableRenice = true;
				settings = {
				};
			};
		};
}
