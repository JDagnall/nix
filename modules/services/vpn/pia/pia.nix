{
    self,
    inputs,
    ...
}: {
    flake.modules.nixos.pia = {config, ...}: let
        # cfg = config.my.services.vpn.pia;
    in {
        # doesn't actaully need this cause there are no options defined
        # but it may be imported multiple times so I may as well
        key = "my/nixos/pia";
        imports = with self.modules.nixos; [vpn sops];
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
