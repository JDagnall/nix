{
	pkgs,
	lib,
	config,
	...
}: let
	inherit (lib) optionals;
in {
	imports = [
		./proton.nix
		./lutris.nix
		./mangohud.nix
		./prism.nix
	];
	options = {
		gaming.heroic.enable = lib.mkEnableOption "Install heroic";
	};
	config = {
		home.packages = [] ++ optionals config.gaming.heroic.enable [pkgs.heroic];
	};
}
