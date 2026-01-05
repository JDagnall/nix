{
	lib,
	config,
	...
}: {
	options = {
		desktop-manager.plasma.enable = lib.mkEnableOption "Enable KDE Plasma 6 user config";
	};
	config =
		lib.mkIf config.desktop-manager.plasma.enable {
			qt.kde = {
				settings = {
					kglobalshortcutsrc = {
						kwin = {
							"Window Close" = "Meta+Q";
							"Window Fullscreen" = "Meta+F";
							"Switch to Desktop 1" = "Meta+1";
							"Switch to Desktop 2" = "Meta+2";
							"Switch to Desktop 3" = "Meta+3";
							"Switch to Desktop 4" = "Meta+4";
							"Switch to Desktop 5" = "Meta+5";
							"Switch to Desktop 6" = "Meta+6";
							"Switch to Desktop 7" = "Meta+7";
							"Switch to Desktop 8" = "Meta+8";
							"Switch to Desktop 9" = "Meta+9";
							"Window to Desktop 1" = "Meta+!";
							"Window to Desktop 2" = "Meta+@";
							"Window to Desktop 3" = "Meta+#";
							"Window to Desktop 4" = "Meta+$";
							"Window to Desktop 5" = "Meta+%";
							"Window to Desktop 6" = "Meta+^";
							"Window to Desktop 7" = "Meta+&";
							"Window to Desktop 8" = "Meta+*";
							"Window to Desktop 9" = "Meta+(";
							"Peek at Desktop" = null;
						};
						"org.kde.krunner.desktop" = {
							_launch = "Meta+D";
						};
					};
				};
			};
			stylix.targets =
				lib.mkIf config.stylix.enableHomeConfig {
					kde = {
						enable = true;
						useWallpaper = true;
						# decorations = "";
					};
					qt.enable = lib.mkDefault true;
				};
		};
}
