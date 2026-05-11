{
	lib,
	config,
	...
}: {
	options = {
		service.qbittorrent = {
			enable = lib.mkEnableOption "Enable qbittorrent service, with a webui.";
			vpnInterface =
				lib.mkOption {
					default = "qbtun0";
					type = lib.types.str;
					description = "qBittorrent connection needs to go through a vpn and this option sets the interface name it will bind to";
				};
		};
		service.jackett.enable = lib.mkEnableOption "Enable jackett, a torrent search interface for qbittorrent.";
		service.flaresolverr.enable = lib.mkEnableOption "Enable flaresolverr, solves captchas.";
	};
	config =
		lib.mkIf config.service.qbittorrent.enable {
			assertions = [
				{
					assertion = config.service.openvpn.enable && config.service.openvpn.PIAqBittorrentService;
					message = "qBittorrent requires a VPN to tunnel through.";
				}
			];
			services.qbittorrent = {
				enable = true;
				user = "qbittorrent";
				group = "qbittorrent";
				extraArgs = ["--confirm-legal-notice"];
				webuiPort = 9494;
				# torrentingPort = ;
				serverConfig = {
					BitTorrent = {
						Session = {
							# bind to vpn device, choosing to do this even if the vpn is not active
							Interface = config.service.qbittorrent.vpnInterface;
							InterfaceName = config.service.qbittorrent.vpnInterface;
							# idk if this is necesary
							# ConnectionInterfaceAddress = "10.63.128.63";
							AddExtensionToIncompleteFiles = true;
							AddTorrentStopped = false;
							# DefaultSavePath = "/driveA";
							GlobalMaxRatio = 1.5;
							GlobalMaxSeedingMinutes = 60;
							QueueingSystemEnabled = true;
							ShareLimitAction = "Stop";
							# TorrentStopCondition = "FilesChecked";
						};
					};
					LegalNotice.Accepted = true;
					Preferences = {
						WebUI = {
							Username = "james";
							Password_PBKDF2 = "@ByteArray(b1ftLzsDQBT52rIa95N6AQ==:H7fEdS+ua5EkRawMWI4JhIosuXx+CgaQsuydDcdUadxAgTClpDVAS10Luln/ZLG0FzEYK+KVryg568X3zS9aIw==)";
						};
						General.Locale = "en";
					};
				};
				openFirewall = true;
			};
			# adding the capability to bind to a network device to qbittorrent service
			systemd.services.qbittorrent.serviceConfig.AmbientCapabilities = "CAP_NET_RAW";
			# provides a torznab searching interface and API
			services.jackett =
				lib.mkIf config.service.jackett.enable {
					enable = true;
					openFirewall = false;
					port = 9117;
					user = "jackett";
					group = "jackett";
					# dataDir =;
				};
			# solves cloudflare captchas
			services.flaresolverr =
				lib.mkIf config.service.jackett.enable {
					enable = true;
					openFirewall = false;
					port = 8191;
				};
		};
}
