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
                # ip tables rules execute in order, we will accept connections on the loopback then tailscale then the VPN and reject all others
                extraCommands = ''
                    ${mkGrpInterfaceRule "A" config.my.network.loopbackInterface "ACCEPT"}
                    ${lib.optionalString config.my.services.tailscale.enabled (mkGrpInterfaceRule "A" config.my.services.tailscale.interface "ACCEPT")}
                    ${mkGrpInterfaceRule "A" cfg.interface "ACCEPT"}
                    iptables -A OUTPUT -m owner --gid-owner ${cfg.group} --suppl-groups -j REJECT || true
                    ip6tables -A OUTPUT -m owner --gid-owner ${cfg.group} --suppl-groups -j REJECT || true
                '';
                # nixos apparently does not clear ip tables rules on rebuild
                extraStopCommands = ''
                    ${mkGrpInterfaceRule "D" config.my.network.loopbackInterface "ACCEPT"}
                    ${lib.optionalString config.my.services.tailscale.enabled (mkGrpInterfaceRule "D" config.my.services.tailscale.interface "ACCEPT")}
                    ${mkGrpInterfaceRule "D" cfg.interface "ACCEPT"}
                    iptables -D OUTPUT -m owner --gid-owner ${cfg.group} --suppl-groups -j REJECT || true
                    ip6tables -D OUTPUT -m owner --gid-owner ${cfg.group} --suppl-groups -j REJECT || true
                '';
            };
        };
    };
}
