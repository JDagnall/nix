# The purpose of this configuration is to host a DNS server for the machine to
# host domain entries pointing to itself on, its not and ad-block / privacy dns server like pihole.
# TODO: I should also seriously consider another DNS server like CoreDNS
# TODO: There probably needs to be a 'dns' parent config so there is no
# overlapping / conflicting servers
{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.dnsmasq-interface = {...}: {
        key = "my/nixos/dnsmasq-interface";
        options = {
            my.servers.dns.dnsmasq = {
                enabled = lib.mkEnableOption "Dnsmasq is enabled as a DNS server.";
            };
        };
    };
    flake.modules.nixos.dnsmasq = {
        pkgs,
        config,
        ...
    }: let
        cfg = config.my.servers.dns.dnsmasq;
        tailscaleEnabled = config.my.services.tailscale.enabled;
        resolvedEnabled = config.services.resolved.enable;
        host = config.networking.hostName;
        physicalInterfaces = config.my.hardware.network.physicalInterfaces;
        tailscaleInterface = config.my.services.tailscale.interface;
        loopbackInterface = config.my.hardware.network.loopbackInterface;
        networkdEnabled = config.networking.useNetworkd;
        activeServices = lib.filter (x: x.mkRevProxy) (lib.attrValues config.my.servers.servers);
    in {
        imports = with self.modules.nixos; [servers tailscale-interface dnsmasq-interface];
        options.my = {
            servers.dns.dnsmasq = {
                hostnames = lib.mkOption {
                    type = with lib.types; listOf str;
                    description = ''
                        Hostnames to create entries for, again just for fowarding subdomains of services.
                        Entries will point back to network address for this machine.
                    '';
                    default = ["${host}.home"];
                };
                tailscaleHostnames = lib.mkOption {
                    type = with lib.types; listOf str;
                    description = ''
                        Hostnames to create entries for on the tailnet, again just for fowarding subdomains of services.
                        Entries will point back to the tailscale network address for this machine.
                    '';
                    default = ["${host}.tail"];
                };
            };
        };
        config = {
            my.servers.dns.dnsmasq.enabled = true;
            warnings = lib.optional (!networkdEnabled) [
                "Dnsmasq may not work well with non systemd-networkd network configs at startup, interfaces may not come up in time for the service"
            ];
            # using dnsmasq with the `interface-name` option creates a race condition
            # at startup where interfaces may not be initialised before dnsmasq intitialises,
            # causing it to crash.
            # networkd has a good soloution to this with the `systemd-networkd-wait-online` tool
            # but NetworkManager does not. TODO: It would be possible to write a service that just
            # checks `ip link` untill an address is configured for the interfaces. But I am not
            # using this with NetworkManager at the moment
            systemd.services.dnsmasq-wait-for-interfaces = lib.mkIf networkdEnabled {
                after = ["systemd-networkd.service"];
                serviceConfig = {
                    Type = "oneshot";
                    ExecStart = let
                        interfaceOpts = map (interface: "-i ${interface}") (physicalInterfaces ++ lib.optional tailscaleEnabled tailscaleInterface);
                    in
                        # Setting a default timeout of 120s, waiting for ipv4 addresses to be specified for the provided interfaces
                        ''
                            ${pkgs.systemd}/lib/systemd/systemd-networkd-wait-online --timeout=120 ${lib.concatStringsSep " " interfaceOpts} --ipv4
                        '';
                    RemainAfterExit = true;
                };
            };
            # inject the systemd dependency
            systemd.services.dnsmasq = lib.mkIf networkdEnabled {
                after = ["dnsmasq-wait-for-interfaces.service"];
                requires = ["dnsmasq-wait-for-interfaces.service"];
            };
            services.dnsmasq = {
                enable = true;
                resolveLocalQueries = !resolvedEnabled;
                settings = {
                    port = 53;
                    address = [];
                    # create dns entry for this device, networks utilising this server should be able to easily navigate to this device
                    # add subdomain for each service configured to run on this machine, annoyingly
                    # interface-name does not support wildcard expansion
                    interface-name = let
                        mkServiceSubdomains = service: hostnames: interfaces:
                            map (hostname:
                                map (
                                    interface:
                                        if service != null
                                        then "${service.name}.${hostname},${interface}"
                                        else "${hostname}.${interface}"
                                )
                                interfaces)
                            hostnames;
                    in
                        lib.lists.flatten [
                            (mkServiceSubdomains null cfg.hostnames physicalInterfaces)
                            (lib.optionals tailscaleEnabled (mkServiceSubdomains null cfg.tailscaleHostnames [tailscaleInterface]))
                            (map (service: mkServiceSubdomains service cfg.hostnames physicalInterfaces) activeServices)
                            (lib.optionals tailscaleEnabled (map (service: mkServiceSubdomains service cfg.tailscaleHostnames [tailscaleInterface]) activeServices))
                        ];

                    # TODO: this will need more work if other configs for other dns servers are added
                    # probably a dns parent config

                    # interfaces that dnsmasq will bind to the default route on, meaning it will eat port 53
                    # for the whole interface
                    interface = physicalInterfaces ++ lib.optional tailscaleEnabled tailscaleInterface ++ lib.optional (!resolvedEnabled) loopbackInterface;

                    # systemd-resolved is slightly tempermental, it cannot easily be moved off of its
                    # default bind of 127.0.0.53-54:53 without potentially breaking other systemd services
                    # so for now when resolved is enabled, dnsmasq can move off of the default loopback address
                    # and then resolved (which will be set as the default stub by systemd) simply points to dnsmasq

                    listen-address = [
                        (
                            if resolvedEnabled
                            then "127.0.0.35"
                            else "127.0.0.1"
                        )
                    ];
                    # except-interface = lib.optionals resolvedEnabled [loopbackInterface];

                    # this means that dnsmasq will only bind to interfaces that are specified not the default route
                    bind-interfaces = true;
                    server = config.networking.nameservers;
                };
            };
            networking.firewall = {
                allowedTCPPorts = [53];
                allowedUDPPorts = [53];
            };
        };
    };
}
