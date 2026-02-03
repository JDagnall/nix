{
	pkgs,
	lib,
	config,
	...
}: {
	options = {
		ui.thunar.enable =
			lib.mkEnableOption {
				description = "Enable thunar config. Currently includes plugins.";
			};
	};
	config =
		lib.mkIf config.ui.thunar.enable {
			home.packages = with pkgs;
				[
					thunar
					xfconf # needed for configuration
				]
				++ [
					thunar-volman # volume manager
					thunar-vcs-plugin # some git integration
					thunar-archive-plugin # managing archive files (extract/compress)
					thunar-media-tags-plugin
				];
			dbus.packages = with pkgs; [thunar xfconf];
			# stylix.targets.xfce.enable = config.stylix.enableHomeConfig;
		};
}
