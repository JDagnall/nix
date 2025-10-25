{
	pkgs,
	lib,
	# config,
	...
}: {
	options = {};
	# host specific stylix
	config = {
		stylix =
			lib.mkForce {
				image = ./wallpapers/A_feverish_Little_Fox_Caldecot.png; # wallpaper, can opt to have theme derived from it
				polarity = "dark"; # prefers dark theme
				base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
				override = {};

				fonts = {
					# define font sizes in differnet contexts. In points, 72 per inch
					sizes = {
						applications = 12;
						desktop = 10;
						popups = 10;
						terminal = 10;
					};
				};
			};
	};
}
