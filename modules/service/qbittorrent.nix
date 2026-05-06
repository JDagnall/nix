{
	lib,
	config,
	...
}: {
	options = {
		service.qbittorrent.enable = lib.mkEnableOption "Enable qbittorrent service, with a webui.";
		service.jackett.enable = lib.mkEnableOption "Enable jackett, a torrent search interface for qbittorrent.";
		service.flaresolverr.enable = lib.mkEnableOption "Enable flaresolverr, solves captchas.";
	};
	config =
		lib.mkIf config.service.qbittorrent.enable {
			services.qbittorrent = {
				enable = true;
				user = "qbittorrent";
				group = "qbittorrent";
				extraArgs = ["--confirm-legal-notice"];
				webuiPort = 9494;
				# torrentingPort = ;
				serverConfig = {
					BitTorrent = {
						ConnectionInterface = "tun0";
						# idk if this is necesary
						ConnectionInterfaceAddress = "10.63.128.63";
						Session = {
							AddExtensionToIncompleteFiles = true;
							AddTorrentStopped = false;
							# DefaultSavePath = "/driveA";
						};
					};
					LegalNotice.Accepted = true;
					Preferences = {
						WebUI = {
							Username = "james";
							Password_PBKDF2 = "@ByteArray(b1ftLzsDQBT52rIa95N6AQ==:H7fEdS+ua5EkRawMWI4JhIosuXx+CgaQsuydDcdUadxAgTClpDVAS10Luln/ZLG0FzEYK+KVryg568X3zS9aIw==)";
						};
						General.Locale = "en";
						# bind to vpn device, choosing to do this even if the vpn is not active
					};
				};
				openFirewall = false;
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
