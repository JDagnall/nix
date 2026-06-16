{
    pkgs,
    lib,
    config,
    ...
}: {
    options = {
        service.tailscale = {
            enable = lib.mkEnableOption "Enable tailscale.";
            tailnet = lib.mkOption {
                description = "The tailnet name, which can be used for magic DNS";
                type = lib.types.nullOr lib.types.str;
                default = null;
            };
            interfaceName = lib.mkOption {
                type = lib.types.str;
                default = "tailscale0";
                description = "The name of the network interface tailscale will use.";
            };
            physicalInterfaces = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [];
                description = "Physical network devices to apply settings to for tailscales performance.";
            };
        };
    };
    config = lib.mkIf config.service.tailscale.enable {
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
            interfaceName = config.service.tailscale.interfaceName;
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
        systemd.services."tailscale-interface-fix" = {
            description = "Apply interface rules to enable disable tcp segmentation for tailscale";
            wants = ["network-pre.target"];
            wantedBy = ["mulit-user.target"];
            serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart = ''
                    ${pkgs.ethtool}/bin/ethtool -K ${config.service.tailscale.interfaceName} tcp-segmentation-offload off generic-segmentation-offload off
                    ${lib.concatStringsSep "\n" (lib.map (x: "${pkgs.ethtool}/bin/ethool -K ${x} rx-udp-gro-forwarding on rx-gro-list off") (config.service.tailscale.physicalInterfaces))}
                '';
            };
        };
        # clamp the MSS from network devices to the tailscale device

        networking.firewall.extraCommands = lib.concatStringsSep "\n" (lib.map (
            interface: ''
                iptables -t mangle -A FORWARD -i ${config.service.tailscale.interfaceName} -o ${interface} -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
                ip6tables -t mangle -A FORWARD -i ${config.service.tailscale.interfaceName} -o ${interface} -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
            ''
        ) (config.service.tailscale.physicalInterfaces));
    };
}
