# The purpose of this configuration is to host a DNS server for the machine to
# host domain entries pointing to itself on, its not and ad-block / privacy dns server like pihole.
{
    lib,
    config,
    ...
}: {
    options = {
        service.dnsmasq = {
            enable = lib.mkEnableOption "Enable dnsmasq, a DNS server only intended for use within a local network.";
            localNetworkInterface = lib.mkOption {
                description = "Network interfaces to listen on for the local network.";
                default = "eth0";
                type = lib.types.str;
            };
            tailscaleNetworkInterface = lib.mkOption {
                description = "Tailscale interfaces to listen on for the tailscale network.";
                default = "tailscale0";
                type = lib.types.str;
            };
        };
    };
    config = let
        host = config.networking.hostName;
        localInterface = config.service.dnsmasq.localNetworkInterface;
        tailscaleEnabled = config.service.tailscale.enable;
        tailscaleInterface = config.service.dnsmasq.tailscaleNetworkInterface;
    in
        lib.mkIf config.service.dnsmasq.enable {
            services.dnsmasq = {
                enable = true;
                resolveLocalQueries = true;
                settings = {
                    address = [];
                    # create dns entry for this device, networks utilising this server should be able to easily navigate to this device
                    interface-name = let
                        mkServiceSubdomain = service: option:
                            if option
                            then ["${service}.${host}.home,${localInterface}"] ++ lib.optionals tailscaleEnabled ["${service}.${host}.tail,${tailscaleInterface}"]
                            else [];
                        serviceCfg = config.service;
                    in
                        [
                            "${host}.home,${localInterface}"
                        ]
                        ++ lib.optionals config.service.tailscale.enable [
                            "${host}.tail,${tailscaleInterface}"
                        ]
                        # add subdomain for each service configured to run on this machine, annoyingly
                        # interface-name does not support wildcard expansion
                        ++ (mkServiceSubdomain "syncthing" serviceCfg.syncthing.enable)
                        ++ (mkServiceSubdomain "qbittorrent" serviceCfg.media-services.qbittorrent.enable)
                        ++ (mkServiceSubdomain "jellyfin" serviceCfg.media-services.jellyfin.enable)
                        ++ (mkServiceSubdomain "sonarr" serviceCfg.media-services.sonarr.enable)
                        ++ (mkServiceSubdomain "radarr" serviceCfg.media-services.radarr.enable)
                        ++ (mkServiceSubdomain "prowlarr" serviceCfg.media-services.prowlarr.enable)
                        ++ (mkServiceSubdomain "flaresolverr" serviceCfg.media-services.flaresolverr.enable)
                        ++ (mkServiceSubdomain "seerr" serviceCfg.media-services.seerr.enable);
                    interface = [localInterface] ++ lib.optionals config.service.tailscale.enable [tailscaleInterface];
                    server = ["1.1.1.1" "8.8.8.8"]; # cloudflaew and google, not really needed
                };
            };
            networking.firewall.allowedTCPPorts = [53];
            networking.firewall.allowedUDPPorts = [53];
        };
}
