{
    pkgs,
    lib,
    config,
    inputs,
    ...
}: let
    cfg = config.service.vpn.pia.wiregaurd;
in {
    imports = [inputs.pia-tools.nixosModules.default];
    options = {
        service.vpn.pia.wiregaurd = {
            enable = lib.mkEnableOption "Enable wiregaurd connection for PIA";
        };
    };
    config = let
        torrentConEnabled = config.service.vpn.pia.torrentCon.enable && config.service.vpn.pia.torrentCon.type == "wiregaurd";
        torrentConInterface = config.service.vpn.pia.torrentCon.interface;
        torrentConPortForward = config.service.vpn.pia.torrentCon.portForward;
    in
        lib.mkIf (config.service.vpn.pia.enable && cfg.enable) {
            assertions =
                []
                ++ lib.optionals torrentConEnabled [
                    {
                        assertion = config.networking.useNetworkd;
                        message = "pia-tools requires systemd-networkd.";
                    }
                ];

            # this is a service written in go specifically for the PIA api
            # there are a couple caveats, 1: it uses systemd networkd.
            # 2: PIA will not keep the connection open indefinetly not gaurantee any specific port
            # This service uses systemd timers to remake the connection and re port forward
            # at a defined interval. Luckily it also includes the functionality to use the transmission
            # and rTorrent API to update the port they use for incoming connections. No current integration
            # for qBittorrent
            # any packets made by a member of the group that are not directed to the
            # the VPN interface are jumped to the REJECT chain
            sops.templates."pia-tools-env" = let
                sops-placeholder = config.sops.placeholder;
            in {
                # can assume based on options that PIA user/pass are set in sops
                content =
                    ''
                        PIA_USERNAME=${sops-placeholder."VPN/PIA/user"}
                        PIA_PASSWORD=${sops-placeholder."VPN/PIA/pass"}
                    ''
                    + lib.optionalString config.service.media-services.qbittorrent.enable ''
                        QBITTORRENT_APIKEY=${sops-placeholder."qbittorrent/apikey"}

                    ''
                    + lib.optionalString config.service.media-services.transmission.enable ''
                        TRANSMISSION_USERNAME=${sops-placeholder."transmission/user"}
                        TRANSMISSION_PASSWORD=${sops-placeholder."transmission/pass"}
                    '';
            };
            boot.kernelModules = ["wireguard"];

            # modules will not make the user & group if it is not the default
            # but i dont want users / groups called just 'pia' (the default)
            users.users."pia-tools" = {
                name = "pia-tools";
                group = "pia-tools";
                description = "pia-tools system user";
                isSystemUser = true;
            };
            users.groups."pia-tools" = {
                name = "pia-tools";
            };
            # TODO: this currently doesnt clean up the netdev and network files if you stop using the service
            # which is not great. This is because the services just run as oneshots on a timer, which
            # should probably be changed
            # could maybe attatch an ExecStop to the timer?
            services.pia-tools = lib.mkIf torrentConEnabled {
                enable = true;
                # package = ;
                user = "pia-tools";
                group = "pia-tools";
                # cacheDir = /run/cache/pia ; # path to tunnel descriptions etc (has pks)
                ifname = torrentConInterface;
                region = "auto"; # should maybe change
                # rTorrentUrl = ; # null or string
                # transmission requires the env file to contain TRANSMISSION_USERNAME and TRANSMISSION_PASSWORD.
                # transmissionUrl = lib.optionalString config.service.media-services.transmission.enable "http://localhost:9091/transmission/rpc/"; # TODO: make this declarative with the port and the urlbase
                qBittorrentUrl = lib.optionalString config.service.media-services.qbittorrent.enable "http://localhost:${toString config.services.qbittorrent.webuiPort}/api/v2";
                envFile = config.sops.templates."pia-tools-env".path;
                # Name of systemd service for pia-tools tunnel reset.
                # resetServiceName = "pia-reset-${ifname}" ; # name of service that resets the conn
                # when the connection is reset (is systemd timer cfg format)
                # resetTimerConfig = {
                #     OnCalendar = "Wed *-*-* 03:00:00";
                #     RandomizedDelaySec = "72h";
                # };
                # refreshServiceName = "pia-pf-refresh-${ifname}" ; # name of service that resets the PF
                # same as above timer cfg but for the port forward
                # refreshTimerConfig = {
                #     OnCalendar = "*-*-* *:00/15:00"; # every 24 hourse
                # };
                # whitelistScript = ; # script to run when connection is made, is passed the new ip
                portForwarding = torrentConPortForward;
                # template files are in go template syntax
                # .netdev file template
                netdevTemplateFile = pkgs.writeText "pia-tools.netdev.tmpl" ''
                    # Configuration for privateinternetaccess.com WireGuard Tunnel
                    # Generated by pia_setup_tunnel on {{ now | date "2006-01-02 15:04:05 MST" }}

                    {{ $tun := . -}}
                    {{ $reg := $tun.Region -}}

                    [NetDev]
                    Name={{ .Interface }}
                    Kind=wireguard

                    [WireGuard]
                    PrivateKey={{ .PrivateKey }}

                    # Region is {{ $reg.Id }} ({{ $reg.Name }} {{ ($tun | server).Cn }}). The ping
                    # time at the time of configuration was {{ $reg.PingTime }}.

                    [WireGuardPeer]
                    Endpoint={{ $tun.ServerIp }}:{{ $tun.ServerPort }}
                    PublicKey={{ $tun.ServerPubkey }}
                    # according to the networkd man page, routing and allowed ips here
                    # in a wiregaurd peer only route within the wireguard network, so I should just
                    # set the default route
                    AllowedIPs=0.0.0.0/0
                    # AllowedIPs={{ $tun.ServerIp }}/32
                    PersistentKeepalive=25
                '';
                # .network file template
                networkTemplateFile = pkgs.writeText "pia-tools.network.tmpl" ''
                    # Configuration for privateinternetaccess.com WireGuard Tunnel
                    # Generated by pia_setup_tunnel on {{ now | date "2006-01-02 15:04:05 MST" }}
                    {{ $if := .Interface -}}
                    {{ $gw := .ServerVip -}}
                    {{ $server_ip := .ServerIp -}}

                    [Match]
                    Name={{ $if }}

                    [Network]
                    Address={{ .PeerIp }}/32
                    Ipv4ReversePathFilter=loose
                    IPv6AcceptRA=no
                    # PIA does not do ipv6
                    LinkLocalAddressing=ipv4
                    {{- range .DnsServers }}
                    DNS={{ . }}
                    {{- end }}

                    # this may be incorrect idk
                    [Route]
                    Destination={{ $gw }}/32
                    # Gateway={{ $server_ip }}
                    # GatewayOnLink=true
                    Scope=link

                    {{ range .DnsServers -}}
                    [Route]
                    Destination={{ . }}/32
                    Gateway={{ $gw }}
                    GatewayOnLink=true
                    {{ end -}}

                    # This would set a default route routing all traffic through the vpn
                    # [Route]
                    # Destination=0.0.0.0/0
                    # Gateway={{ $gw }}
                    # GatewayOnLink=true
                    # Scope=global

                '';
                # netdevFile = ; # where to put the generated .netdev
                # networkFile = ; # where to put the generated .network
            };
        };
}
