{
    self,
    lib,
    inputs,
    ...
}: {
    flake.modules.nixos.qbittorrent = {
        pkgs,
        config,
        ...
    }: {
        imports = with self.modules.nixos; [servers arr sops vpn];
        config = let
            arrCfg = config.my.servers.arr;
            # cfg = config.my.servers.arr.qbittorrent;
            serverCfg = config.my.servers.servers.qbittorrent;
            vpnCfg = config.my.services.vpn.pia.torrentCon;
            torrentVPNInterface = vpnCfg.interface;
            inherit (builtins) concatStringsSep isAttrs isString;
            inherit (lib) collect mapAttrsRecursive escape replaceString;
            inherit (lib.generators) mkValueStringDefault mkKeyValueDefault toINI;
            # taken from nixpkgs https://github.com/NixOS/nixpkgs/blob/0bb7ec54c8483066ec9d7720e780a5caa71f8612/nixos/modules/services/torrent/qbittorrent.nix#L37
            # allows ini with more that just one layer of attrs
            gendeepINI = toINI {
                mkKeyValue = let
                    sep = "=";
                in
                    k: v:
                        if isAttrs v
                        then
                            concatStringsSep "\n" (
                                collect isString (
                                    mapAttrsRecursive (
                                        path: value: "${escape [sep] (concatStringsSep "\\" ([k] ++ path))}${sep}${
                                            replaceString "\n" "\\n" (mkValueStringDefault {} value)
                                        }"
                                    )
                                    v
                                )
                            )
                        else mkKeyValueDefault {} sep k v;
            };
        in {
            # should bind the service to a vpn interface
            my.services.vpn.torrentCon.groupMembers = [serverCfg.user];
            my.servers.servers.qbittorrent = rec {
                port = 9494;
                user = "qbittorrent";
                group = arrCfg.group.name;
                mkRevProxy = true;
                # qbittorrent really doesnt like being proxied so these headers
                # get set to stop it from denying the request
                extraRevProxyCfg = ''
                    header_up Host localhost:${toString port}
                    header_up X-Forwarded-Host {hostport}
                    header_up -Origin
                    header_up -Referer
                '';
            };
            sops.secrets = let
                host = config.networking.hostName;
                secretCfg = {
                    sopsFile = "${inputs.secrets}/${host}/qbittorrent.yaml";
                };
            in {
                "qbittorrent/user" = secretCfg;
                "qbittorrent/pass" = secretCfg;
                "qbittorrent/hashedPass" = secretCfg;
                "qbittorrent/apikey" = secretCfg;
            };
            sops.templates = {
                "qbittorrent-config" = {
                    mode = "400";
                    owner = config.services.qbittorrent.user;
                    # .conf for qbittorrent, which would usually go in the serverConfig attr in the module
                    # however we want to inject secrets.
                    content = gendeepINI {
                        BitTorrent = {
                            Session = {
                                # bind to vpn device, choosing to do this even if the vpn is not active
                                InterfaceName = torrentVPNInterface;
                                Interface = torrentVPNInterface;
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
                                # Port = ; # this is the peer connection port
                            };
                        };
                        LegalNotice.Accepted = true;
                        Network = {
                            PortForwardingEnabled = false; # This is UPNP which can be insecure
                        };
                        Preferences = {
                            WebUI = {
                                Username = config.sops.placeholder."qbittorrent/user";
                                Password_PBKDF2 = config.sops.placeholder."qbittorrent/hashedPass";
                                APIKey = config.sops.placeholder."qbittorrent/apikey";
                            };
                            General = {
                                Locale = "en";
                                StatusbarExternalIPDisplayed = true;
                            };
                        };
                    };
                };
            };
            services.qbittorrent = {
                enable = true;
                user = serverCfg.user;
                group = serverCfg.group;
                extraArgs = ["--confirm-legal-notice"];
                webuiPort = serverCfg.port;
                # torrentingPort = ;
                serverConfig = {};
                openFirewall = serverCfg.openFirewall;
            };
            systemd.services."qbittorrent".serviceConfig = {
                # The module ususally does this with a config file generated from the serverConfig attr,
                # however we are creating the config from a sops template to include secrets.
                ExecStartPre = lib.mkForce ''
                    ${pkgs.coreutils}/bin/install -Dm600 ${config.sops.templates."qbittorrent-config".path} "${config.services.qbittorrent.profileDir}/qBittorrent/config/qBittorrent.conf"
                '';
                # adding the capability to bind to a network device to qbittorrent service
                # should not be needed now it is bound with IP tables rules
                # AmbientCapabilities = "CAP_NET_RAW";
                # Umask = "0007";
            };
        };
    };
}
