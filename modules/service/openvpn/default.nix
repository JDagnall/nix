{
	pkgs,
	lib,
	config,
	...
}: {
	options = {
		service.openvpn = {
			enable = lib.mkEnableOption {description = "Enable openvpn config";};
			PIA = lib.mkEnableOption "Enable PIA openvpn connections with networkmanager connections ans systemd services.";
		};
	};
	config =
		lib.mkIf config.service.openvpn.enable {
			services.openvpn = {
				restartAfterSleep = true;
				# these get turned into system services
				servers = {
					PIA-Melbourne =
						lib.mkIf config.service.openvpn.PIA {
							config = ''config ${builtins.toString ./servers/PIA_melbourne.ovpn}'';
							autoStart = false;
							updateResolvConf = true;
						};
					PIA-Brisbane =
						lib.mkIf config.service.openvpn.PIA {
							config = ''config ${builtins.toString ./servers/PIA_brisbane.ovpn}'';
							autoStart = false;
							updateResolvConf = true;
						};
				};
			};

			# sops.secrets = let
			# 	host = config.networking.hostName;
			# in
			# 	lib.mkIf config.sops.enable {
			# 		"VPN/PIA/user" =
			# 			lib.mkIf config.service.openvpn.PIA {
			# 				sopsFile = ../../secrets/${host}/vpn.yaml;
			# 			};
			# 		"VPN/PIA/pass" =
			# 			lib.mkIf config.service.openvpn.PIA {
			# 				sopsFile = ../../secrets/${host}/vpn.yaml;
			# 			};
			# 	};
			networking.networkmanager.plugins =
				lib.mkIf config.networking.networkmanager.enable [
					pkgs.networkmanager-openvpn
				];
			networking.networkmanager = {
				# use google and cloudflare nameservers
				insertNameservers = ["8.8.8.8" "1.1.1.1"];
				ensureProfiles = {
					profiles = {
						PIA_openvpn_brisbane = {
							connection = {
								id = "PIA_openvpn_brisbane";
								type = "vpn";
							};
							ipv4 = {
								dns = "8.8.8.8;1.1.1.1;";
								method = "auto";
							};
							ipv6 = {
								method = "disabled";
							};
							proxy = {};
							vpn = {
								ca = "${./servers/cert.pem}";
								password-flags = "1"; # secrets should be managed by secret service
								challenge-response-flags = "2";
								auth = "sha1";
								cipher = "aes-128-gcm";
								compress = "yes";
								connection-type = "password";
								dev = "tun";
								remote = "au-brisbane-pf.privacy.network:1198";
								remote-cert-tls = "server";
								reneg-seconds = "0";
								service-type = "org.freedesktop.NetworkManager.openvpn";
							};
						};
						PIA_openvpn_melbourne = {
							connection = {
								id = "PIA_openvpn_melbourne";
								type = "vpn";
							};
							ipv4 = {
								dns = "8.8.8.8;1.1.1.1;";
								method = "auto";
							};
							ipv6 = {
								method = "disabled";
							};
							proxy = {};
							vpn = {
								ca = "${./servers/cert.pem}";
								challenge-response-flags = "2";
								password-flags = "1"; # secrets should be managed by secret service
								auth = "sha1";
								cipher = "aes-128-gcm";
								compress = "yes";
								connection-type = "password";
								dev = "tun";
								remote = "aus-melbourne.privacy.network:1198";
								remote-cert-tls = "server";
								reneg-seconds = "0";
								service-type = "org.freedesktop.NetworkManager.openvpn";
							};
						};
					};
					# secrets.entries = [
					# 	{
					# 		file = config.sops.target."VPN/PIA/user".path;
					# 		key = "auth-user";
					# 		matchId = "PIA_openvpn_melbourne";
					# 		matchSetting = "vpn";
					# 		matchType = "vpn";
					# 	}
					# 	{
					# 		file = config.sops.target."VPN/PIA/pass".path;
					# 		key = "auth-user-pass";
					# 		matchId = "PIA_openvpn_melbourne";
					# 		matchSetting = "vpn";
					# 		matchType = "vpn";
					# 	}
					# ];
				};
			};
		};
}
