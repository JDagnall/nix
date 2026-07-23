{
    lib,
    config,
    ...
}: let
    cfg = config.service.media-services.transmission;
    mediaCfg = config.service.media-services;
    piaCfg = config.service.vpn.pia;
in {
    options = {
        service.media-services.transmission = {
            enable = lib.mkEnableOption "Enable transmission download client";
        };
    };
    config = lib.mkIf (cfg.enable && mediaCfg.enable) {
        assertions = [
            {
                assertion = config.service.vpn.pia.torrentCon.enable;
                message = "Transmission requires a VPN to tunnel through.";
            }
        ];
        service.vpn.pia.torrentCon.groupMembers = lib.optionals piaCfg.torrentCon.updateTransmissionPort [config.services.transmission.user];
        sops.secrets = let
            host = config.networking.hostName;
        in
            lib.mkIf config.sops.enable {
                "transmission/user" = {
                    sopsFile = ../../../secrets/${host}/transmission.yaml;
                };
                "transmission/pass" = {
                    sopsFile = ../../../secrets/${host}/transmission.yaml;
                };
                "transmission/hashedPass" = {
                    sopsFile = ../../../secrets/${host}/transmission.yaml;
                };
            };
        sops.templates = {
            "transmissionCredentials" = {
                content = builtins.toJSON {
                    "rpc_username" = config.sops.placeholder."transmission/user";
                    "rpc_password" = config.sops.placeholder."transmission/hashedPass";
                };
                owner = config.services.transmission.user;
                mode = "600";
            };
        };
        services.transmission = {
            enable = true;
            # extraFlags = ;
            # home = ;
            user = "transmission";
            group = mediaCfg.group.name;
            credentialsFile = config.sops.templates."transmissionCredentials".path;
            downloadDirPermissions = "770";
            openPeerPorts = false; # TODO: find out if this needs to be enabled with a VPN port forward (probably not)
            openRPCPort = false; # tailscale + caddy
            performanceNetParameters = false;
            # webHome = ;
            settings = {
                # transmission config docs https://github.com/transmission/transmission/blob/main/docs/Editing-Configuration-Files.md
                # RPC
                rpc-authentication-required = true;
                rpc-bind-address = "127.0.0.1"; # only local host
                rpc-port = 9091;
                rpc-enabled = true;
                anti-brute-force-enabled = true;
                anti-brute-force-threshold = 100;
                rpc-url = "/transmission/";
                rpc-whitelist = "127.0.0.1";
                rpc-whitelist-enabled = false;
                rpc-host-whitelist = "localhost";
                rpc-host-whitelist-enabled = false;

                # IP ANNOUNCE
                # announce-ip = "";
                # announce-ip-enabled = false;

                # BANDWIDTH
                # alt-speed-enabled = false;
                # alt-speed-up = 50;
                # alt-speed-down = 50;
                # speed-limit-down = 100; # KB/s
                # speed-limit-down-enabled = false;
                # speed-limit-up = 100; # KB/s
                # speed-limit-up-enabled = false;
                # upload-slots-per-torrent = 14;

                # BLOCKLIST
                # blocklist-url = "";
                # blocklist-enabled = false;

                # DIRECTORIES & FILES
                # download-dir = ;
                # incomplete-dir = ;
                incomplete-dir-enabled = true;
                # preallocation = 1;
                # rename-parital-files = true;
                # start-added-torrents = true;
                # trash-can-enabled = true;
                # trash-original-torrent-files = false;
                umask = "007";
                # watch-dir = ;
                # watch-dir-enabled = false;
                # watch-dir-force-generic = false;

                # MISC
                # cache-size-mib = 4;
                # default-trackers = "";
                # dht-enabled = true;
                # encryption = "allowed";
                # ip-endpoints-ipv4 = "";
                # ip-endpoints-ipv6 = "";
                # lpd-enabled = false;
                message-level = 2;
                # pex-enabled = true;
                # pidfile = "";
                # proxy-url = "";
                # scrape-paused-torrents-enabled = true;
                # script-torrent-added-enabled = false;
                # script-torrent-added-filename = null;
                # script-torrent-done-enabled = false;
                # script-torrent-done-filename = null;
                # script-torrent-done-seeding-enabled = false;
                # script-torrent-done-seeding-filename = null;
                # start-paused = false;
                # tcp-enabled = true; # deprecated use preferred-transports
                # torrent-added-verify-mode = "fast";
                # torrent-complete-verify-enabled = false;
                # utp-enabled = true; # deprecated use prederred-transports
                # preffered-transports = ["tcp" "utp"];
                # sleep-per-seconds-during-verify = 100

                # PEER CONNECTION
                bind-address-ipv4 = "10.71.2.106";
                # bind-address-ipv6 = ;
                # peer-congestion-algorithm = ;
                # peer-limit-global = 200;
                # peer-limit-per-torrent = 50;
                # peer-limit-socket-diffserv = "le";
                # reqq = 2000;
                # sequential-download = false;

                # PEER PORT
                # peer-port = 51413; # will get set by pia-tools dynamically
                # peer-port-random-high = 65535;
                # peer-port-random-low = 65535;
                # peer-port-random-on-start = false;
                # port-forwarding-enabled = true;

                # QUEUING
                download-queue-enabled = true;
                download-queue-size = 5;
                queue-stalled-enabled = true;
                queue-stalled-minutes = 30;
                seed-queue-enabled = true;
                seed-queue-size = 5;

                # SCHEDULING
                seed-ratio-limit = 2.0;
                seed-ratio-limted = true;
                idle-seeding-limit = 30; # min
                idle-seeding-limit-enabled = true;
            };
        };
    };
}
