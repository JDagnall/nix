# The purpose of this configuration is to host a DNS server for the machine to
# host domain entries pointing to itself on, its not and ad-block / privacy dns server like pihole.
{
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
        # using dnsmasq witht the tailscale interface creates a race condition
        # at startup where tailscale may not have created it's interface before
        # dnsmasq intitialises, causing it to crash. So we just start it after tailscale
        systemd.services.dnsmasq.after = lib.optionals tailscaleEnabled ["tailscaled.service"];
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
