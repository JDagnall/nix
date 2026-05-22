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
					tailnet = config.service.tailscale.tailnet;
					tailscaleEnabled = config.service.tailscale.enable && tailnet != null;
					domainAliases = ["home" "tail"] ++ lib.optionals tailscaleEnabled ["${tailnet}.ts.net"];
					servicesCfg = config.service;
					mkServiceSubDomain = name: port: {
						"${name}.${host}.local" = {
							extraConfig = ''
								tls internal
								reverse_proxy localhost:${toString port}
							'';
							serverAliases = lib.map (x: "${name}.${host}.${x}") domainAliases;
						};
					};
					mkServicePath = name: port: ''
						handle_path /${name}* {
							reverse_proxy localhost:${toString port}
						}
					'';
				in
					{
						"${host}.local" = {
							extraConfig = ''
								tls internal
								root /etc/${default_http_path}
								file_server
								${lib.optionalString servicesCfg.syncthing.enable (mkServicePath "syncthing" 8384)}
								${lib.optionalString servicesCfg.media-services.qbittorrent.enable (mkServicePath "qbittorrent" 9494)}
								${lib.optionalString servicesCfg.media-services.jellyfin.enable (mkServicePath "jellyfin" 8096)}
								${lib.optionalString servicesCfg.media-services.sonarr.enable (mkServicePath "sonarr" 8989)}
								${lib.optionalString servicesCfg.media-services.prowlarr.enable (mkServicePath "prowlarr" 9696)}
								${lib.optionalString servicesCfg.media-services.flaresolverr.enable (mkServicePath "flaresolverr" 8191)}
							'';
							serverAliases = lib.map (x: "${host}.${x}") domainAliases;
						};
					}
					// lib.optionalAttrs servicesCfg.syncthing.enable (mkServiceSubDomain "syncthing" 8384)
					// lib.optionalAttrs servicesCfg.media-services.qbittorrent.enable (mkServiceSubDomain "qbittorrent" 9494)
					// lib.optionalAttrs servicesCfg.media-services.jellyfin.enable (mkServiceSubDomain "jellyfin" 8096)
					// lib.optionalAttrs servicesCfg.media-services.sonarr.enable (mkServiceSubDomain "sonarr" 8989)
					// lib.optionalAttrs servicesCfg.media-services.prowlarr.enable (mkServiceSubDomain "prowlarr" 9696)
					// lib.optionalAttrs servicesCfg.media-services.flaresolverr.enable (mkServiceSubDomain "flaresolverr" 8191);
			};
		};
}
