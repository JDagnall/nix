# This config specifically is just for allowing access to advertised services through subdomains
# anything else to do with reverse proxying, will be put in a separate file
{
	lib,
	config,
	...
}: {
	options = {
		service.caddy = {
			enable = lib.mkEnableOption "Enable caddy, a reverse proxy.";
			email =
				lib.mkOption {
					description = "Email to use for the acme certificates.";
					type = lib.types.nullOr lib.types.str;
					default = null;
				};
		};
	};
	config = let
		# cfg = config.service.caddy;
		# default route http server location
		# relative to /etc
		default_http_path = "caddy/www";
	in
		lib.mkIf config.service.caddy.enable {
			environment.etc."${default_http_path}/index.html" = {
				source = ./caddy_index.html;
				user = config.services.caddy.user;
				group = config.services.caddy.group;
			};
			services.caddy = {
				enable = true;
				openFirewall = true;
				# acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
				# dataDir = ;
				enableReload = false;
				# environmentFile = ; # sops
				email = config.service.caddy.email;
				extraConfig = "";
				globalConfig = "";
				# user = "caddy";
				# group = "caddy";
				# httpPort = ;
				# httpsPort = ;
				# logDir = ;
				# settings = {};
				virtualHosts = let
					host = config.networking.hostName;
					# servicesCfg = config.service;
				in {
					"${host}.local" = {
						extraConfig = ''
							tls internal
							root = /etc/${default_http_path}
						'';
						serverAliases = [];
					};
				};
			};
		};
}
