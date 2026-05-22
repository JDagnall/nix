{
	# pkgs,
	lib,
	config,
	...
}: {
	options = {
		service.tailscale.enable = lib.mkEnableOption "Enable tailscale.";
	};
	config =
		lib.mkIf config.service.tailscale.enable {
			sops.secrets."tailscale/authKey" = let
				host = config.networking.hostName;
			in
				lib.mkIf config.sops.enable {
					sopsFile = ../../secrets/${host}/tailscale.yaml;
				};
			services.tailscale = {
				enable = true;
				useRoutingFeatures = "client"; # client, server, none or both
				port = 41641;
				openFirewall = true;
				permitCertUid = null;
				interfaceName = "tailscale0";
				extraUpFlags = [];
				extraSetFlags = [];
				extraDaemonFlags = [];
				# disableUpstreamLogging = true;
				disableTaildrop = true;
				# this is custom DERP servers not the default ones.
				derper = {
					enable = false;
					port = 8010;
					stunPort = 3478;
					openFirewall = true;
					# domain = "";
					# configureNginx = false;
					# verifyClients = true;
				};
				# authKeyParameters = {
				# 	preauthorized = null;
				# 	ephemeral = null;
				# 	baseUrl = null;
				# };
				authKeyFile = config.sops.secrets."tailscale/authKey".path;
			};
			# networking.extraHosts = "${config.networking.hostName}.home ${config.networking.hostName}";
		};
}
