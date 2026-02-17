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
		gaming.protonplus.enable = lib.mkEnableOption "Install protonplus";
	};
	config = let
		inherit (config.gaming) heroic protonplus;
	in {
		home.packages =
			[]
			++ optionals heroic.enable [pkgs.heroic]
			++ optionals protonplus.enable [pkgs.protonplus];
	};
}
