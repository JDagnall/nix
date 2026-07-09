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
        };
    };
    config = lib.mkIf (cfg.enable && cfg.qbittorrent.enable) {
        assertions = [
            {
                assertion = config.service.openvpn.enable && config.service.openvpn.PIATorrentService;
                message = "Qbittorrent requires a VPN to tunnel through.";
            }
        ];
        users.groups.${config.service.openvpn.PIATorrentGroupName}.members = [config.users.users."qbittorrent".name];
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
                        InterfaceName = config.service.openvpn.PIATorrentDevName;
                        Interface = config.service.openvpn.PIATorrentDevName;
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
        systemd.services.qbittorrent.serviceConfig = {
            # adding the capability to bind to a network device to qbittorrent service
            AmbientCapabilities = "CAP_NET_RAW";
            Umask = "0007";
        };
    };
}
