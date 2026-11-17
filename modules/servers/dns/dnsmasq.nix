# The purpose of this config is to add local domain entries
# to interface-name
{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.dnsmasqServer = {
        pkgs,
        config,
        ...
    }: let
        # cfg = config.my.servers.dns.dnsmasq;
        # resolvedEnabled = config.services.resolved.enable;
        networkdEnabled = config.networking.useNetworkd;
        dnsCfg = config.my.services.dns;
        dnsServerCfg = config.my.servers.dns;
        localDomains = dnsServerCfg.localDomains;
        interfaces = dnsServerCfg.interfaces;
        # loopbackInterface = config.my.hardware.network.loopbackInterface;
    in {
        key = "my/nixos/dnsmasq-server";
        imports = with self.modules.nixos; [servers dnsServer dnsmasq];
        # options.my = { servers.dns.dnsmasq = {}; };
        config = {
            assertions = [
                {
                    assertion = dnsCfg.type == "dnsmasq";
                    message = "Cannot enable dnsmasq as a server if it is not enabled as a service.";
                }
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
                        # cannot have `lo` or any loopback interface in the wait
                        # list otherwise it will just fail
                        interfaceOpts = map (interface: "-i ${interface}") (lib.lists.remove "lo" interfaces);
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
                settings = {
                    # this restricts responses to the subnets they came in on
                    # it makes it possible to have the same domain to have multiple
                    # `interface-name` entries for example
                    localise-queries = true;
                    # can use `/4` or `/6` to specify only ipv4 / ipv6
                    interface-name =
                        lib.concatMap (interface: map (domain: "${domain},${interface}") localDomains)
                        interfaces;

                    # interfaces that dnsmasq will bind to the default route on, meaning it will eat port 53
                    # for the whole interface
                    interface = interfaces;
                    # except-interface = lib.optional resolvedEnabled loopbackInterface;
                    # this means that dnsmasq will only bind to interfaces that are specified not the default route
                    bind-interfaces = true;
                };
            };
        };
    };
}
