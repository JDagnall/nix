# TODO: this should really all be moved to coredns
{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.orion = {config, ...}: {
        imports = with self.modules.nixos; [tailscale-interface dnsmasq];
        config = {
            services.dnsmasq.settings = let
                activeServices = lib.filter (x: x.mkRevProxy) (lib.attrValues config.my.servers.servers);
                tailscaleEnabled = config.my.services.tailscale.enabled;
                domain = "waluigimangione.dev";
                localIp = "192.168.1.2";
                tailscaleIp = "100.121.250.78";
                mkSubdomain = service: (["/${service.name}.${domain}/${localIp}"] ++ lib.optional tailscaleEnabled "/${service.name}.${domain}/${tailscaleIp}");
            in {
                address = ["/${domain}/${localIp}"] ++ lib.optional tailscaleEnabled "/${domain}/${tailscaleIp}" ++ (builtins.concatLists (map mkSubdomain activeServices));
            };
        };
    };
}
