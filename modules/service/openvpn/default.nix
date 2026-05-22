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
			PIAqBittorrentService = lib.mkEnableOption "Autostarted service, that doesn't redirect non-bound traffic. Intended for qBitorrent to use.";
			defaultInterfaceName =
				lib.mkOption {
					default = "tun";
					type = lib.types.str;
					description = "Name of the interface the vpn will create and bind to. Not specifying a number will assign a dynamic one.";
				};
		};
	};
	config =
		lib.mkIf config.service.openvpn.enable {
			assertions = [
				{
					assertion = config.sops.enable;
					message = "Openvpn requires sops to be enabled to retrieve credentials.";
				}
			];

			sops =
				lib.mkIf config.sops.enable {
					secrets = let
						host = config.networking.hostName;
					in {
						"VPN/PIA/user" = {
							sopsFile = ../../../secrets/${host}/vpn.yaml;
						};
						"VPN/PIA/pass" = {
							sopsFile = ../../../secrets/${host}/vpn.yaml;
						};
					};
					templates = {
						"PIA-login" =
							lib.mkIf (config.service.openvpn.PIA || config.service.openvpn.PIAqBittorrentService) {
								content = ''
									${config.sops.placeholder."VPN/PIA/user"}
									${config.sops.placeholder."VPN/PIA/pass"}
								'';
							};
						"NetworkManager-profiles-env" =
							lib.mkIf config.service.openvpn.PIA {
								content =
									''''
									+ lib.optionalString config.service.openvpn.PIA
									"PIA_USERNAME=${config.sops.placeholder."VPN/PIA/user"}";
							};
					};
				};

			services.openvpn = let
				defaultDevice = config.service.openvpn.defaultInterfaceName;
				qbittorrentDevice = config.service.media-services.qbittorrent.vpnInterface;
			in {
				restartAfterSleep = true;
				# these get turned into system services
				servers = {
					PIA-Melbourne =
						lib.mkIf config.service.openvpn.PIA {
							config = ''
								config ${toString ./servers/PIA_melbourne.ovpn}
								auth-nocache
								dev ${defaultDevice}
							'';
							autoStart = false;
							updateResolvConf = true;
							authUserPass = config.sops.templates."PIA-login".path;
						};
					PIA-Brisbane =
						lib.mkIf config.service.openvpn.PIA {
							config = ''
								config ${toString ./servers/PIA_brisbane.ovpn}
								auth-nocache
								dev ${defaultDevice}
							'';
							autoStart = false;
							updateResolvConf = true;
							authUserPass = config.sops.templates."PIA-login".path;
						};
					# will only redirect traffic bound to qbittorrentDevice
					PIA-qBittorrent =
						lib.mkIf config.service.openvpn.PIAqBittorrentService {
							config = ''
								config ${toString ./servers/PIA_melbourne.ovpn}
								pull-filter ignore redirect-gateway
								auth-nocache
								dev ${qbittorrentDevice}
								dev-type tun
							'';
							autoStart = true;
							updateResolvConf = true;
							authUserPass = config.sops.templates."PIA-login".path;
						};
				};
			};

			# systemd.services.NetworkManager-profiles-env = {
			# 	description = "Create env file for NetworkManager-ensure-profiles.service from sops secrets.";
			# 	wantedBy = ["multi-user.target"];
			# 	before = ["network-online.target" "NetworkManager-ensure-profiles.service"];
			# 	after = ["NetworkManager.service"];
			# 	script = let
			# 		dir = "/run/secrets/VPN";
			# 		file = "/run/secrets/VPN/NetworkManager-ensure-profiles.env";
			# 	in
			# 		''
			# 			mkdir -p ${dir}
			# 			if [ -a ${file} ]; then
			# 			    rm ${file}
			# 			fi
			# 			touch ${file}
			# 			chmod 600 ${file}
			# 		''
			# 		+ lib.optionalString config.service.openvpn.PIA
			# 		''echo "PIA_USERNAME=$(cat ${config.sops.secrets."VPN/PIA/user".path})\n" >> ${file}'';
			# 	serviceConfig = {
			# 		Umask = "0177";
			# 		Type = "oneshot";
			# 	};
			# };

			networking.networkmanager =
				lib.mkIf config.networking.networkmanager.enable {
					plugins = [
						pkgs.networkmanager-openvpn
					];
					# use google and cloudflare nameservers
					# insertNameservers = ["8.8.8.8" "1.1.1.1"];
					ensureProfiles = {
						environmentFiles = [
							config.sops.templates."NetworkManager-profiles-env".path
						];
						profiles = {
							PIA_openvpn_brisbane =
								lib.mkIf config.service.openvpn.PIA {
									connection = {
										id = "PIA_openvpn_brisbane";
										type = "vpn";
										autoconnect = false;
									};
									ipv4 = {
										# first two are PIA DNS
										dns = "10.0.0.242;10.0.0.243;8.8.8.8;1.1.1.1;";
										method = "auto";
									};
									ipv6 = {
										method = "disabled";
									};
									proxy = {};
									vpn = {
										ca = "${./servers/cert.pem}";
										# password-flags = "0"; # secrets stored in network manager root readable file
										password-flags = "1"; # secrets stored in nm-file-secret-agent
										username = "$PIA_USERNAME";
										challenge-response-flags = "x-dynamic-challenge-echo:challenge-response";
										# auth-user-pass = 1;
										auth = "sha256";
										proto-tcp = "no";
										cipher = "aes-256-cbc";
										# compress = "yes";
										comp-lzo = "no";
										dev = "tun";
										remote = "au-brisbane-pf.privacy.network:1197";
										port = 1197;
										remote-cert-tls = "server";
										# tls-client = 1;
										reneg-seconds = "0";
										# verb = 4;
										service-type = "org.freedesktop.NetworkManager.openvpn";
										connection-type = "password";
									};
								};
							PIA_openvpn_melbourne =
								lib.mkIf config.service.openvpn.PIA {
									connection = {
										id = "PIA_openvpn_melbourne";
										type = "vpn";
										autoconnect = false;
									};
									ipv4 = {
										# first two are PIA DNS
										dns = "10.0.0.242;10.0.0.243;8.8.8.8;1.1.1.1;";
										method = "auto";
									};
									ipv6 = {
										method = "disabled";
									};
									proxy = {};
									vpn = {
										ca = "${./servers/cert.pem}";
										# password-flags = "0"; # secrets stored in network manager root readable file
										password-flags = "1"; # secrets stored in nm-file-secret-agent
										username = "$PIA_USERNAME";
										challenge-response-flags = "x-dynamic-challenge-echo:challenge-response";
										# challenge-response-flags = "1";
										auth = "sha256";
										proto-tcp = "no";
										cipher = "aes-256-cbc";
										# compress = "yes";
										comp-lzo = "no";
										dev = "tun";
										remote = "aus-melbourne.privacy.network:1197";
										port = 1197;
										remote-cert-tls = "server";
										# tls-client = 1;
										reneg-seconds = "0";
										# verb = 4;
										service-type = "org.freedesktop.NetworkManager.openvpn";
										connection-type = "password";
									};
								};
						};
						# for openvpn at the moment network manager defaults to using the gnome keyring to store passwords.
						# secrets.entries =
						# 	[]
						# 	++ lib.optionals config.service.openvpn.PIA [
						# 		{
						# 			file = config.sops.secrets."VPN/PIA/pass".path;
						# 			key = "password";
						# 			matchId = "PIA_openvpn_melbourne";
						# 			matchSetting = "vpn";
						# 			matchType = "vpn";
						# 		}
						# 		{
						# 			file = config.sops.secrets."VPN/PIA/pass".path;
						# 			key = "password";
						# 			matchId = "PIA_openvpn_brisbane";
						# 			matchSetting = "vpn";
						# 			matchType = "vpn";
						# 		}
						# 	];
					};
				};
		};
}
