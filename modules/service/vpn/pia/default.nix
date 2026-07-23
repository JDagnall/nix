{
    config,
    lib,
    ...
}: let
    cfg = config.service.vpn.pia;
in {
    imports = [
        ./openvpn.nix
        ./wiregaurd.nix
    ];
    options = {
        service.vpn.pia = {
            enable = lib.mkEnableOption "Enable PIA vpn config";
            torrentCon = {
                enable = lib.mkEnableOption ''
                    Enable a connection for PIA intended for torrent clients.
                    This connection will only tunnel programs that are bound to it through
                    membership to a group. This connection has port forwarding functionality
                    if done through wiregaurd.
                '';
                type = lib.mkOption {
                    type = lib.types.enum ["wiregaurd" "openvpn"];
                    description = "Whether to open the connection with wiregaurd (pia-tools) or openvpn.";
                };
                interface = lib.mkOption {
                    type = lib.types.str;
                    default = "piatorr0";
                    description = "Name of the network interface created.";
                };
                group = lib.mkOption {
                    type = lib.types.str;
                    default = "piawgtorr";
                    description = "Name of the group that binds users to this interface.";
                };
                groupMembers = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    default = [];
                    description = "Members of the torrent connection group, members will be bound to the connection interface with iptables rules.";
                };
                portForward = lib.mkEnableOption "Port forward the VPN connection. Will only open on random port. Only works with the wiregaurd connection.";
                updateTransmissionPort = lib.mkOption {
                    default = config.service.media-services.transmission.enable && (cfg.torrentCon.type == "wiregaurd");
                    type = lib.types.bool;
                    description = "Whether to update the forwarded port in the transmission RPC";
                };
            };
        };
    };
    config = lib.mkIf cfg.enable {
        sops.secrets = let
            host = config.networking.hostName;
        in
            lib.mkIf config.sops.enable {
                "VPN/PIA/user" = {
                    sopsFile = ../../../../secrets/${host}/vpn.yaml;
                };
                "VPN/PIA/pass" = {
                    sopsFile = ../../../../secrets/${host}/vpn.yaml;
                };
            };
        assertions =
            [
                {
                    assertion = config.sops.enable;
                    message = "PIA VPN requires sops to provide login secrets.";
                }
            ]
            ++ lib.optionals cfg.torrentCon.enable [
                {
                    assertion = (cfg.torrentCon.type == "wiregaurd" && cfg.wiregaurd.enable) || (cfg.torrentCon.type == "openvpn" && cfg.openvpn.enable);
                    message = "The torrent connection type must also be enabled (wiregaurd or openvpn).";
                }
                {
                    assertion = (lib.match "[^0-9]+[0-9]" cfg.torrentCon.interface) != null;
                    message = ''
                        The device name specified for the torrent device must include a number at the end, otherwise one will
                        be assigned to it by default and the configuration will not have access to the correct device name.
                    '';
                }
            ]
            ++ lib.optionals cfg.torrentCon.portForward [
                {
                    assertion = cfg.torrentCon.type == "wiregaurd";
                    message = "Wiregaurd is required for port forwarding the torrent connection.";
                }
            ]
            ++ lib.optionals cfg.torrentCon.updateTransmissionPort [
                {
                    assertion = config.service.media-services.transmission.enable;
                    message = "Transmission needs to be enabled in order to configure pia-tools to update its port.";
                }
                {
                    assertion = cfg.torrentCon.portForward;
                    message = "`portForward` must be enabled for the vpn connection to dynamically update transmissions peer port.";
                }
            ];
        users.groups.${cfg.torrentCon.group} = {
            name = cfg.torrentCon.group;
            members = cfg.torrentCon.groupMembers;
        };
        # any packets made by a member of the group that are not directed to the
        # the VPN interface are jumped to the REJECT chain
        networking.firewall = let
            mkGrpInterfaceRule = cmd: interface: jump-table: ''
                iptables -${cmd} OUTPUT -m owner --gid-owner ${cfg.torrentCon.group} --suppl-groups -o ${interface} -j ACCEPT || true
                ip6tables -${cmd} OUTPUT -m owner --gid-owner ${cfg.torrentCon.group} --suppl-groups -o ${interface} -j ACCEPT || true
            '';
        in
            lib.mkIf cfg.torrentCon.enable {
                # ip tables rules execute in order, we will accept connections on the loopback then tailscale then the VPN and reject all others
                extraCommands = ''
                    ${mkGrpInterfaceRule "A" config.network.loopbackInterface "ACCEPT"}
                    ${lib.optionalString config.service.tailscale.enable (mkGrpInterfaceRule "A" config.service.tailscale.interface "ACCEPT")}
                    ${mkGrpInterfaceRule "A" cfg.torrentCon.interface "ACCEPT"}
                    iptables -A OUTPUT -m owner --gid-owner ${cfg.torrentCon.group} --suppl-groups -j REJECT || true
                    ip6tables -A OUTPUT -m owner --gid-owner ${cfg.torrentCon.group} --suppl-groups -j REJECT || true
                '';
                # nixos apparently does not clear ip tables rules on rebuild
                extraStopCommands = ''
                    ${mkGrpInterfaceRule "D" config.network.loopbackInterface "ACCEPT"}
                    ${lib.optionalString config.service.tailscale.enable (mkGrpInterfaceRule "D" config.service.tailscale.interface "ACCEPT")}
                    ${mkGrpInterfaceRule "D" cfg.torrentCon.interface "ACCEPT"}
                    iptables -D OUTPUT -m owner --gid-owner ${cfg.torrentCon.group} --suppl-groups -j REJECT || true
                    ip6tables -D OUTPUT -m owner --gid-owner ${cfg.torrentCon.group} --suppl-groups -j REJECT || true
                '';
            };
    };
}
