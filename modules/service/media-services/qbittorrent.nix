{
    lib,
    config,
    ...
}: let
    cfg = config.service.media-services;
in {
    options = {
        service.media-services.qbittorrent = {
            enable = lib.mkEnableOption "Enable qbittorrent service, with a webui.";
            vpnInterface = lib.mkOption {
                default = "qbtun0";
                type = lib.types.str;
                description = "qBittorrent connection needs to go through a vpn and this option sets the interface name it will bind to";
            };
        };
    };
    config = lib.mkIf (cfg.enable && cfg.qbittorrent.enable) {
        assertions = [
            {
                assertion = config.service.openvpn.enable && config.service.openvpn.PIAqBittorrentService;
                message = "qBittorrent requires a VPN to tunnel through.";
            }
        ];
        services.qbittorrent = {
            enable = true;
            user = "qbittorrent";
            group = cfg.group.name;
            extraArgs = ["--confirm-legal-notice"];
            webuiPort = 9494;
            # torrentingPort = ;
            serverConfig = {
                BitTorrent = {
                    Session = {
                        # bind to vpn device, choosing to do this even if the vpn is not active
                        Interface = cfg.qbittorrent.vpnInterface;
                        InterfaceName = cfg.qbittorrent.vpnInterface;
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
                    General = {
                        Locale = "en";
                        StatusbarExternalIPDisplayed = true;
                    };
                };
            };
            openFirewall = true;
        };
        # adding the capability to bind to a network device to qbittorrent service
        systemd.services.qbittorrent.serviceConfig.AmbientCapabilities = "CAP_NET_RAW";
    };
}
