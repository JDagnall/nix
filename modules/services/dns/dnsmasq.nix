# The purpose of this configuration is to host a DNS service for local resoloution
# on this machine. For forwarding this server, inorder for it to be used by other devices
# see `my.servers.dnsServer` and `my.servers.dnsmasqServer`
{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.dnsmasq = {config, ...}: let
        # cfg = config.my.services.dns.dnsmasq;
        networkdEnabled = config.networking.useNetworkd;
        resolvedEnabled = config.services.resolved.enable;
        dnsCfg = config.my.services.dns;
        # loopbackInterface = config.my.hardware.network.loopbackInterface;
    in {
        key = "my/nixos/dnsmasq";
        imports = with self.modules.nixos; [dns];
        # options.my = {
        #     services.dns.dnsmasq = { };
        # };
        config = {
            my.services.dns.type = "dnsmasq";
            warnings = lib.optional (!networkdEnabled) [
                "Dnsmasq may not work well with non systemd-networkd network configs at startup, interfaces may not come up in time for the service"
            ];
            services.dnsmasq = {
                enable = true;
                resolveLocalQueries = !resolvedEnabled;
                settings = {
                    port = 53;

                    # can use `/4` or `/6` to specify only ipv4 / ipv6
                    # dnsmasq does not support wildcard expansion
                    address = map (entry: "/${entry.domain}/${entry.ip}") (lib.filter (entry: !entry.wildcard) dnsCfg.entries);

                    no-resolv = true; # we want the configuration in nix not resolv.conf

                    # this means that dnsmasq will only bind to interfaces that are specified not the default route
                    server = config.networking.nameservers;

                    # will make dnsmasq not fight for 127.0.0.1 if system-resolved is enabled
                    listen-address = [
                        dnsCfg.loopbackListenAddress
                    ];
                };
            };
        };
    };
}
