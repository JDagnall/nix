{
	lib,
	config,
	...
}: let
	cfg = config.service.media-services;
in {
	options = {
		service.media-services = {
			prowlarr.enable = lib.mkEnableOption "Enable Prowlarr.";
			flaresolverr.enable =
				lib.mkOption {
					type = lib.types.bool;
					default = cfg.prowlarr.enable;
					description = "Enable flaresolverr, solves captchas.";
				};
		};
	};
	config =
		lib.mkIf cfg.enable {
			services.prowlarr =
				lib.mkIf cfg.prowlarr.enable {
					enable = true;
					openFirewall = false; # tailscale;
					# dataDir = ;
					# environmentFiles = []; #sops
					settings = {
						log.analyticsEnabled = false;
						server = {
							port = 9696;
							bindaddress = "localhost";
							# would be 'prowlar', if intended to access through reverse proxy,
							# in format domain-name.com/prowlarr
							# urlbase = ;
						};
						update.automatically = false;
					};
				};
			# solves cloudflare captchas
			services.flaresolverr =
				lib.mkIf cfg.flaresolverr.enable {
					enable = true;
					openFirewall = false;
					port = 8191;
				};
		};
}
