{
    self,
    lib,
    inputs,
    ...
}: {
    flake.modules.nixos.ssh = {...}: {
        imports = with self.modules.home; [sops];
        config = {
            sops.secrets = {
                "ssh/publicKeys/james/orion" = {
                    sopsFile = "${inputs.secrets}/common/ssh.yaml";
                };
            };
        };
    };
    flake.modules.nixos.orion.james = {config, ...}: {
        imports = with self.modules.nixos; [sops ssh];
        config = {
            sops.templates."ssh-james-authorizedKeys" = let
                authedKeys = ["james/framework" "james/book" "james/pc"];
            in {
                path = "/etc/ssh/authorized_keys.d/james";
                owner = "james";
                group = "james";
                mode = "600";
                content = lib.concatStringsSep "\n" (map (host: "${config.sops.placeholder."ssh/publicKeys/${host}"}") authedKeys);
            };
        };
    };
}
