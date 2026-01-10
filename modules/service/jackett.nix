{
	lib,
	config,
	...
}: {
	options = {
		service.jackett.enable = lib.mkEnableOption "Enable jackett config.";
	};
	config =
		lib.mkIf config.service.jackett.enable {
			# provides a torznab searching interface and API
			services.jackett = {
				enable = true;
				openFirewall = false;
				port = 9117;
				user = "jackett";
				group = "jackett";
				# dataDir =;
			};
			# solves cloudflare captchas
			services.flaresolverr = {
				enable = true;
				openFirewall = false;
				port = 8191;
			};
		};
}
