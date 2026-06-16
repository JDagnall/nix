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
            interfacePatch = lib.mkEnableOption "Some network interfaces (specifically NIC's with driver r8169) need certain settings disabled to work smoothly";
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

        # needed for service
        environment.systemPackages = lib.mkIf config.service.tailscale.interfacePatch [pkgs.ethtool pkgs.gnugrep];
        systemd.services."tailscale-interface-patch" = lib.mkIf config.service.tailscale.interfacePatch {
            enable = true;
            description = "Apply interface rules to fix driver checksum bug for r8169 drivers with tailscale.";
            after = ["tailscaled.service"];
            wants = ["tailscaled.service"];
            wantedBy = ["mulit-user.target"];
            script = let
                tailscaleInterfaceScript = interface: ''
                    ${pkgs.ethtool}/bin/ethtool -K ${interface} tso off gso off || true;
                    echo ${interface}:
                    ${pkgs.ethtool}/bin/ethtool -k ${interface} | ${pkgs.gnugrep}/bin/grep -E 'tcp-segmentation-offload|generic-segmentation-offload' || true;
                    echo '\n'
                '';
                physInterfaceScript = interface: ''
                    ${pkgs.ethtool}/bin/ethtool -K ${interface} tso off gso off gro off lro off rx off tx off || true;
                    echo ${interface}:
                    ${pkgs.ethtool}/bin/ethtool -k ${interface} | ${pkgs.gnugrep}/bin/grep -E 'rx-checksumming|tx-checksumming|tcp-segmentation-offload|generic-segmentation-offload|generic-receive-offload|large-receive-offload' || true;
                    echo '\n'
                '';
            in ''
                ${tailscaleInterfaceScript config.service.tailscale.interfaceName}
                ${lib.concatStringsSep "\n" (map physInterfaceScript (config.service.tailscale.physicalInterfaces))}
            '';
            serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
            };
        };
        # clamp the MSS from the tailscale device to network devices
        networking.firewall.extraCommands = lib.mkIf config.service.tailscale.interfacePatch (lib.concatStringsSep "\n" (map (
            interface: ''
                iptables -t mangle -A FORWARD -i ${config.service.tailscale.interfaceName} -o ${interface} -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
                ip6tables -t mangle -A FORWARD -i ${config.service.tailscale.interfaceName} -o ${interface} -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
            ''
        ) (config.service.tailscale.physicalInterfaces)));
    };
}
