{
	lib,
	config,
	...
}: {
	options = {
		desktop-manager.xfce.enable = lib.mkEnableOption "Enable xfce config.";
	};
	config =
		lib.mkIf config.desktop-manager.xfce.enable {
			services.xserver.desktopManager.xfce = {
				enable = true;
				enableWaylandSession = true;
				enableScreensaver = true;
			};
		};
}
