# TODO: desperately need some kind of dns parent config
{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.resolved = {config, ...}: let
        # cfg = config.my.services.resolved;
    in {
        imports = with self.modules.nixos; [avahi-interface dnsmasq-interface network];
        # the nixos module for systemd-resolved will always bind port 53
        # any other running DNS servers will have to be delegates of resolved.
        options = {
            my.services.resolved = {
                openFirewall = lib.mkEnableOption "open port 53";
            };
        };
        config = {
            services.resolved = {
                enable = true;
                # could use dnsmasq as a delegate, but its just less complicated to add it as a DNS server
                # dnsDelegates = let
                #     dnsmasqCfg = config.my.services.dnsmasq; would need an interface patter
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
                        dnsmasqCfg = config.my.servers.dns.dnsmasq;
                    in {
                        DNS = lib.optionals dnsmasqCfg.enabled [dnsmasqCfg.loopbackListenAddress] ++ config.networking.nameservers;
                        #     DNSOverTLS = false;
                        #     DNSSEC = false;
                        #     # unqualified name lookups
                        #     Domains = config.networking.search;
                        MulticastDNS = !config.my.services.avahi.enabled;
                    };
                };
            };
        };
    };
}
