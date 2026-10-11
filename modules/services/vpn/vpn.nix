{
    self,
    lib,
    ...
}: {
    # not sure if there is any generalised vpn options.
    # there would be if i wanted to enforce only one connection / type.
    flake.modules.nixos.vpn = {...}: {
        options = {};
    };

    # A connection for PIA intended for torrent clients.
    # This connection will only tunnel programs that are bound to it through
    # membership to a group. This connection has port forwarding functionality
    # if done through wiregaurd.
    flake.modules.nixos.vpn-torrent-connection = {config, ...}: let
        cfg = config.my.services.vpn.torrentCon;
    in {
        imports = [self.modules.nixos.vpn];
        options = {
            my.services.vpn.torrentCon = {
                type = lib.mkOption {
                    type = with lib.types; nullOr enum ["pia-tools"];
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
    };
}
