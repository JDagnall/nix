{
	lib,
	config,
	...
}: let
	inherit (lib) mkIf mkEnableOption;
in {
	options = {
		display-manager.ly.enable =
			mkEnableOption {
				default = false;
				description = "Enable ly display manager";
			};
	};
	config =
		mkIf config.display-manager.ly.enable {
			services.displayManager.ly = {
				enable = true;
				# package = pkgs.ly;
				# x11Support = true;
				settings = {
				};
			};
		};
}
