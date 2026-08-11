# The purpose of this configuration is to host a DNS server for the machine to
# host domain entries pointing to itself on, its not and ad-block / privacy dns server like pihole.
# TODO: This module does have some generalisation problems, using the `interface` options
# should be some kind of enable option. Something to fix after dendritic is implimented.
{
    pkgs,
    lib,
    config,
    ...
}: let
    cfg = config.service.dnsmasq;
    tailscaleEnabled = config.service.tailscale.enable;
    resolvedEnabled = config.service.resolved.enable;
    host = config.networking.hostName;
    physicalInterfaces = config.network.physicalInterfaces;
    tailscaleInterface = config.service.tailscale.interface;
    loopbackInterface = config.network.loopbackInterface;
    networkdEnabled = config.networking.useNetworkd;
in {
    options = {
        service.dnsmasq = {
            enable = lib.mkEnableOption "Enable dnsmasq, a DNS server only intended for use within a local network.";
            openFirewall = lib.mkEnableOption "Open ports 53." // {default = true;};
            topLevelDomains = lib.mkOption {
                type = with lib.types; listOf str;
                description = ''
                    Top level domains dnsmasq will have an entry for. Mostly so other services know which domains to redirect to dnsmasq.
                    DNSmasq should have entries for at least {hostname}.{topLevelDomain}.
                '';
                default = ["home"] ++ lib.optionals tailscaleEnabled ["tail"];
            };
            loopbackListenAddress = lib.mkOption {
                type = lib.types.str;
                default =
                    if resolvedEnabled
                    then "127.0.0.35"
                    else "127.0.0.1";
                description = ''
                    The listen addres for the loopback device. Will listen on port 53 at this address.
                    This is intended to be able to move dnsmasq off of the default route and listen address
                    in the case of conflicting DNS servers, like systemd-resolved.
                '';
            };
        };
    };
    config = lib.mkIf config.service.dnsmasq.enable {
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
                # port = cfg.port;
                address = [];
                # create dns entry for this device, networks utilising this server should be able to easily navigate to this device
                interface-name = let
                    mkServiceSubdomain = service: option:
                        if option
                        then
                            (lib.map (phys: "${service}.${host}.home,${phys}") physicalInterfaces)
                            ++ lib.optionals tailscaleEnabled ["${service}.${host}.tail,${tailscaleInterface}"]
                        else [];
                    serviceCfg = config.service;
                in
                    (lib.map (phys: "${host}.home,${phys}") physicalInterfaces)
                    ++ lib.optionals config.service.tailscale.enable [
                        "${host}.tail,${tailscaleInterface}"
                    ]
                    # add subdomain for each service configured to run on this machine, annoyingly
                    # interface-name does not support wildcard expansion
                    ++ (mkServiceSubdomain "syncthing" serviceCfg.syncthing.enable)
                    ++ (mkServiceSubdomain "qbittorrent" serviceCfg.media-services.qbittorrent.enable)
                    ++ (mkServiceSubdomain "transmission" serviceCfg.media-services.transmission.enable)
                    ++ (mkServiceSubdomain "jellyfin" serviceCfg.media-services.jellyfin.enable)
                    ++ (mkServiceSubdomain "sonarr" serviceCfg.media-services.sonarr.enable)
                    ++ (mkServiceSubdomain "radarr" serviceCfg.media-services.radarr.enable)
                    ++ (mkServiceSubdomain "prowlarr" serviceCfg.media-services.prowlarr.enable)
                    ++ (mkServiceSubdomain "flaresolverr" serviceCfg.media-services.flaresolverr.enable)
                    ++ (mkServiceSubdomain "jackett" serviceCfg.media-services.jackett.enable)
                    ++ (mkServiceSubdomain "seerr" serviceCfg.media-services.seerr.enable);

                # TODO: this will need more work if other configs for other dns servers are added
                # probably a dns parent config

                # interfaces that dnsmasq will bind to the default route on, meaning it will eat port 53
                # for the whole interface
                interface = physicalInterfaces ++ lib.optionals tailscaleEnabled [tailscaleInterface] ++ lib.optionals (!resolvedEnabled) [loopbackInterface];

                # systemd-resolved is slightly tempermental, it cannot easily be moved off of its
                # default bind of 127.0.0.53-54:53 without potentially breaking other systemd services
                # so for now when resolved is enabled, dnsmasq can move off of the default loopback address
                # and then resolved (which will be set as the default stub by systemd) simply points to dnsmasq

                listen-address = [cfg.loopbackListenAddress];
                # except-interface = lib.optionals resolvedEnabled [loopbackInterface];

                # this means that dnsmasq will only bind to interfaces that are specified not the default route
                bind-interfaces = true;
                server = config.networking.nameservers;
            };
        };
        networking.firewall = lib.mkIf cfg.openFirewall {
            allowedTCPPorts = [53];
            allowedUDPPorts = [53];
        };
    };
}
