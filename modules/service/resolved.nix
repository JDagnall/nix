{
    lib,
    config,
    ...
}: let
    cfg = config.service.resolved;
in {
    # the nixos module for systemd-resolved will always bind port 53
    # any other running DNS servers will have to be delegates of resolved.
    options = {
        service.resolved = {
            enable = lib.mkEnableOption "Enable systemd-resolved config.";
            openFirewall = lib.mkEnableOption "open port 53";
        };
    };
    config = lib.mkIf cfg.enable {
        services.resolved = {
            enable = true;
            # could use dnsmasq as a delegate, but its just less complicated to add it as a DNS server
            # dnsDelegates = let
            #     dnsmasqCfg = config.service.dnsmasq;
            #     host = config.networking.hostName;
            # in {
            #     "dnsmasq" = lib.mkIf dnsmasqCfg.enable {
            #         Delegate = {
            #             DNS = ["localhost:${toString dnsmasqCfg.port}"];
            #             Domains = lib.map (x: "${host}.${x}") dnsmasqCfg.topLevelDomains;
            #             # DefaultRoute = false;
            #             # FirewallMark = ;
            #         };
            #     };
            # };
            settings = {
                # DNSStubResolver = ;
                # DNSStubListenerExtra = ;
                Resolve = let
                    dnsmasqCfg = config.service.dnsmasq;
                in {
                    DNS = lib.optionals dnsmasqCfg.enable [dnsmasqCfg.loopbackListenAddress] ++ config.networking.nameservers;
                    #     DNSOverTLS = false;
                    #     DNSSEC = false;
                    #     # unqualified name lookups
                    #     Domains = config.networking.search;
                    MulticastDNS = !config.service.avahi.enable; # would conflict with avahi
                };
            };
        };
    };
}
