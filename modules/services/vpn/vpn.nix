{
    self,
    lib,
    ...
}: {
    # not sure if there is any generalised vpn options.
    # there would be if i wanted to enforce only one connection / type.
    flake.modules.nixos.vpn = {...}: {
        key = "my/nixos/vpn";
        options = {};
    };

    # A connection for PIA intended for torrent clients.
    # This connection will only tunnel programs that are bound to it through
    # membership to a group. This connection has port forwarding functionality
    # if done through wiregaurd.
    flake.modules.nixos.vpn-torrent-connection = {config, ...}: let
        cfg = config.my.services.vpn.torrentCon;
    in {
        key = "my/nixos/vpn-torrent-connection";
        imports = with self.modules.nixos; [vpn tailscale-interface network];
        options = {
            my.services.vpn.torrentCon = {
                type = lib.mkOption {
                    type = with lib.types; nullOr (enum ["pia-tools"]);
                    default = null;
                    description = ''
                        Whichever module is handling the torrent connection.
                        Should probably only be one.
                    '';
                };
                interface = lib.mkOption {
                    type = lib.types.str;
                    default = "torr0";
                    description = "Name of the network interface created.";
                };
                group = lib.mkOption {
                    type = lib.types.str;
                    default = "wgtorr";
                    description = "Name of the group that binds users to this interface.";
                };
                groupMembers = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    default = [];
                    description = "Members of the torrent connection group, members will be bound to the connection interface with iptables rules.";
                };
                portForward = lib.mkEnableOption "Port forward the VPN connection. Will only open on random port. Only works with the wiregaurd connection.";
                listenPort = lib.mkOption {
                    type = lib.types.port;
                    default = 17553;
                    description = ''
                        The listen port for the torrent connection, this is for
                        iptables rules, any modules implementing this interface
                        will need to support it. But of course the modules could also
                        set this option. This also assumes that the torrent connection
                        is wiregaurd (or at least UDP), this could be adjusted / made
                        configurable but at the moment I have no use for that.
                    '';
                };
            };
        };
        config = {
            assertions = [
                {
                    assertion = cfg.type != null;
                    message = "A VPN torrent connection needs to be specified. A module is importing a connection";
                }
            ];
            users.groups.${cfg.group} = {
                name = cfg.group;
                members = cfg.groupMembers;
            };
            # any packets made by a member of the group that are not directed to the
            # the VPN interface are jumped to the REJECT chain
            networking.firewall = let
                mkGrpInterfaceRule = cmd: interface: jump-table: ''
                    iptables -${cmd} OUTPUT -m owner --gid-owner ${cfg.group} --suppl-groups -o ${interface} -j ACCEPT || true
                    ip6tables -${cmd} OUTPUT -m owner --gid-owner ${cfg.group} --suppl-groups -o ${interface} -j ACCEPT || true
                '';
            in {
                # not a huge fan of this as it will allow all incoming traffic from the vpn provider
                # but the alternative is managing an iptables chain that gets updated as the forwarded port
                # does, which probably means another PR to pia-tools and I don't wanna.
                # TODO: maybe do the iptables chain idk
                # trustedInterfaces = lib.optional cfg.portForward cfg.interface;
                # ip tables rules execute in order, if a packet is attributed to the torrentCon group
                # we will accept connections on the loopback then tailscale then the VPN, Also packets on any interface
                # if and only if they come from the source port of the torrent connections listen port and are UDP (wiregaurd)
                # Any packet that does not match those criteria and is attributed to the torrent con group is rejected
                extraCommands = ''
                    ${mkGrpInterfaceRule "A" config.my.hardware.network.loopbackInterface "ACCEPT"}
                    ${lib.optionalString config.my.services.tailscale.enabled (mkGrpInterfaceRule "A" config.my.services.tailscale.interface "ACCEPT")}
                    ${mkGrpInterfaceRule "A" cfg.interface "ACCEPT"}
                    iptables -A OUTPUT -m owner --gid-owner ${cfg.group} --suppl-groups -p udp --sport ${toString cfg.listenPort} -j ACCEPT || true
                    ip6tables -A OUTPUT -m owner --gid-owner ${cfg.group} --suppl-groups -p udp --sport ${toString cfg.listenPort} -j ACCEPT || true
                    iptables -A OUTPUT -m owner --gid-owner ${cfg.group} --suppl-groups -j REJECT || true
                    ip6tables -A OUTPUT -m owner --gid-owner ${cfg.group} --suppl-groups -j REJECT || true
                '';
                # nixos apparently does not clear ip tables rules on rebuild
                extraStopCommands = ''
                    ${mkGrpInterfaceRule "D" config.my.hardware.network.loopbackInterface "ACCEPT"}
                    ${lib.optionalString config.my.services.tailscale.enabled (mkGrpInterfaceRule "D" config.my.services.tailscale.interface "ACCEPT")}
                    ${mkGrpInterfaceRule "D" cfg.interface "ACCEPT"}
                    iptables -D OUTPUT -m owner --gid-owner ${cfg.group} --suppl-groups -p udp --sport ${toString cfg.listenPort} -j ACCEPT || true
                    ip6tables -D OUTPUT -m owner --gid-owner ${cfg.group} --suppl-groups -p udp --sport ${toString cfg.listenPort} -j ACCEPT || true
                    iptables -D OUTPUT -m owner --gid-owner ${cfg.group} --suppl-groups -j REJECT || true
                    ip6tables -D OUTPUT -m owner --gid-owner ${cfg.group} --suppl-groups -j REJECT || true
                '';
            };
        };
    };
}
