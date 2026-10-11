{
    self,
    inputs,
    ...
}: {
    flake.modules.nixos.pia = {config, ...}: let
        # cfg = config.service.vpn.pia;
    in {
        import = with self.modules.nixos; [vpn sops];
        config = {
            sops.secrets = let
                host = config.networking.hostName;
                secretCfg = {sopsFile = "${inputs.secrets}/${host}/vpn.yaml";};
            in {
                "VPN/PIA/user" = secretCfg;
                "VPN/PIA/pass" = secretCfg;
            };
        };
    };
}
