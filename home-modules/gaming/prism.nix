{
	pkgs,
	config,
	lib,
	...
}: {
	options = {
		gaming.prism.enable = lib.mkEnableOption "Enable Prism Launcher for minecraft";
	};
	config =
		lib.mkIf config.gaming.prism.enable {
			home.packages = with pkgs; [prismlauncher];
		};
}
