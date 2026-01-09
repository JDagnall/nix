{
	pkgs,
	lib,
	config,
	...
}: {
	options = {
		desktop-manager.plasma.enable = lib.mkEnableOption "Enable KDE Plasma 6 config";
	};
	config =
		lib.mkIf config.desktop-manager.plasma.enable {
			services.desktopManager.plasma6 = {
				enable = true;
				enableQt5Integration = true;
			};
			services.displayManager.sddm = {
				enable = lib.mkDefault true;
				wayland.enable = true;
				wayland.compositor = "kwin";
			};
			qt = {
				enable = true;
				platformTheme = "qt5ct";
				style = "kvantum";
			};
			hardware = {
				# Opengl
				graphics.enable = true;
			};

			# XDG portal
			xdg.portal.enable = true;
			xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

			environment.systemPackages = with pkgs; [kdePackages.qtstyleplugin-kvantum libsForQt5.qtstyleplugin-kvantum rose-pine-kvantum libxcb-cursor];
			# services.xserver.enable = true; # maybe unecessary
			# # mostly just all of the added on stuff
			# environment.plasma6.excludePackages = with pkgs.kdePackages; [
			# konsole
			# dolphin
			# kwin-x11
			# ark
			# elisa
			# gwenview
			# okular
			# kate
			# ktexteditor
			# khelpcenter
			# dolphin-plugins
			# spectacle
			# krdp
			# ];
		};
}
