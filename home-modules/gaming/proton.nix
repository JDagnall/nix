{
	pkgs,
	lib,
	config,
	...
}: let
	inherit (lib) mkEnableOption optionals;
in {
	options = {
		gaming.proton.ge.enable =
			mkEnableOption {
				description = ''
					Enable Proton-GE. This is a fork that is supposed to be slightly better. 
					               The command protonup installs and updates it to the latest version.'';
			};
	};
	config = {
		home.packages = with pkgs; [] ++ optionals config.gaming.proton.ge.enable [protonup];
	};
}
