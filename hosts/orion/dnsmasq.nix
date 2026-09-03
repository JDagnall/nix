# This is just a patch since the config here obviously does not belong with the general
# config in modules. Dendritic suits this far better.
{
    lib,
    config,
    ...
}: {
    options = {
        service.dnsmasq.orion = {
            enable = lib.mkEnableOption "Enable the specific domain configuration for orion";
            domainName = lib.mkOption {
                type = lib.types.str;
                description = "The domain name to configure cloudflare for.";
            };
            # not super happy with this.
            # denritic can partially fix it but the real soloution is to run 2 dnsmasq instances
            # or something like coredns may be a better fit
            localIp = lib.mkOption {
                type = lib.types.str;
                description = "The local IP to point the domain to";
            };
            tailscaleIp = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                description = "The tailscale IP to point the domain to";
                default = null;
            };
        };
    };
    config = lib.mkIf config.service.dnsmasq.orion.enable {
        assertions = [
            {
                assertion = config.service.dnsmasq.enable;
                message = "Dnsmasq must be enabled to enable the specific orion configuration.";
            }
        ];
        services.dnsmasq.settings = let
            activeServices = config.service.media-services.activeServices;
            domain = config.service.dnsmasq.orion.domainName;
            tailscaleEnabled = config.service.tailscale.enable;
            localIp = config.service.dnsmasq.orion.localIp;
            tailscaleIp = config.service.dnsmasq.orion.tailscaleIp;
            mkSubdomain = service: (["/${domain}/${localIp}"] ++ lib.optional tailscaleEnabled "/${domain}/${tailscaleIp}");
        in {
            address = ["/${domain}/${localIp}"] ++ lib.optional tailscaleEnabled "/${domain}/${tailscaleIp}" ++ (builtins.concatLists (map mkSubdomain activeServices));
        };
    };
}
