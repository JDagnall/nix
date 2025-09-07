{
	pkgs,
	lib,
	config,
	...
}: let
	inherit (lib) mkIf mkEnableOption;
in {
	options = {
		display-manager.sddm.enable =
			mkEnableOption {
				default = false;
				description = "Enable sddm display manager";
			};
	};
	config =
		mkIf config.display-manager.sddm.enable {
			environment.systemPackages = with pkgs; [(catppuccin-sddm.override {flavor = "mocha";})];
			services.displayManager.sddm = {
				enable = true;
				wayland.enable = true;
				theme = "catppuccin-mocha";
				package = pkgs.kdePackages.sddm;
			};
		};
}
