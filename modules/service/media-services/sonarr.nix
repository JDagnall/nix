{
	lib,
	config,
	...
}: let
	cfg = config.service.media-services;
in {
	options = {
		service.media-services.sonarr.enable = lib.mkEnableOption "Enable Sonarr.";
	};
	config =
		lib.mkIf (cfg.enable && cfg.sonarr.enable) {
			services.sonarr = {
				enable = true;
				openFirewall = false; # tailscale;
				# dataDir = ;
				# user = ;
				group = cfg.group.name;
				# environmentFiles = []; #sops
				settings = {
					log.analyticsEnabled = false;
					server = {
						port = 8989;
						bindaddress = "localhost";
						# would be 'prowlar', if intended to access through reverse proxy,
						# in format domain-name.com/prowlarr
						# urlbase = ;
					};
					update.automatically = false;
				};
			};
		};
}
