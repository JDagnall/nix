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
				image = ../../wallpapers/cyberpunk.png;
				polarity = "dark"; # prefers dark theme
				base16Scheme = "${pkgs.base16-schemes}/share/themes/ashes.yaml";
				override = {};

				fonts = {
					# define font sizes in differnet contexts. In points, 72 per inch
					sizes = {
						applications = 12;
						desktop = 10;
						popups = 12;
						terminal = 12;
					};
				};
			};
	};
}
