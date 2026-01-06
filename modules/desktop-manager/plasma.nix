{
	# pkgs,
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
			# # mostly just all of the added on stuff
			# environment.plasma6.excludePackages = with pkgs.kdePackages; [
			# 	konsole
			# 	dolphin
			# 	kwin-x11
			# 	ark
			# 	elisa
			# 	gwenview
			# 	okular
			# 	kate
			# 	ktexteditor
			# 	khelpcenter
			# 	dolphin-plugins
			# 	spectacle
			# 	krdp
			# ];
		};
}
