{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.dnsServer = {config, ...}: let
        cfg = config.my.servers.dns;
    in {
        key = "my/nixos/dnsServer";
        imports = with self.modules.nixos; [dns servers tailscale-interface];
        options = {
            my.servers.dns = {
                openFirewall = lib.mkEnableOption "Open port 53 to act as a DNS server.";
                localDomains = lib.mkOption {
                    description = ''
                        These are domains that point back to this device, so it will
                        return the address of whatever interface the request came
                        in on. Not all DNS services can do this.
                    '';
                    type = with lib.types; listOf str;
                    default =
                        (lib.concatMap (server: server.dns.domains) (
                            lib.filter (server: server.dns.enable) (
                                lib.attrValues config.my.servers.servers
                            )
                        ))
                        ++ config.my.servers.publicHostNames;
                };
                interfaces = let
                    defaultIfs =
                        config.my.hardware.network.physicalInterfaces
                        ++ [config.my.hardware.network.loopbackInterface]
                        ++ lib.optional config.my.services.tailscale.enabled config.my.services.tailscale.interface;
                in
                    lib.mkOption {
                        type = with lib.types; listOf str;
                        default = defaultIfs;
                        description = "Interfaces to assosciate the local domains with.";
                    };
            };
        };
        config = {
            networking.firewall.allowedUDPPorts = lib.optional cfg.openFirewall 53;
            networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall 53;
        };
    };
}
