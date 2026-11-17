{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.resolved = {config, ...}: let
        # cfg = config.my.services.resolved;
    in {
        imports = with self.modules.nixos; [avahi-interface network];
        # the nixos module for systemd-resolved will always bind port 53
        # any other running DNS servers will have to be delegates of resolved.
        options = {
            my.services.resolved = {
            };
        };
        config = {
            services.resolved = {
                enable = true;
                settings = {
                    # DNSStubResolver = ;
                    # DNSStubListenerExtra = ;
                    Resolve = let
                    in {
                        DNS = config.networking.nameservers;
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
    # this is for if resolved is going to be enabled anyway because networkd is
    # point it at the actual DNS service
    flake.modules.nixos.dns = {config, ...}: {
        key = "my/nixos/dns-resolved-patch";
        config = let
            resolvedEnabled = config.services.resolved.enable;
        in
            lib.mkIf resolvedEnabled {
                # overwrite other nameservers so it just redirects straight to the
                # actual name server
                services.resolved.settings.Resolve.DNS = lib.mkForce [config.my.services.dns.loopbackListenAddress];
            };
    };
}
