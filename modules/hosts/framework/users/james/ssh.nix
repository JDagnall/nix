{
    self,
    lib,
    inputs,
    ...
}: {
    flake.modules.nixos.ssh = {...}: {
        imports = with self.modules.nixos; [sops];
        config = {
            sops.secrets = {
                "ssh/publicKeys/james/framework" = {
                    sopsFile = "${inputs.secrets}/common/ssh.yaml";
                };
            };
        };
    };
    flake.modules.nixos.framework-james = {config, ...}: {
        imports = with self.modules.nixos; [sops ssh];
        config = {
            sops.templates."ssh-james-authorizedKeys" = let
                authedKeys = ["james/pc"];
            in {
                path = "/etc/ssh/authorized_keys.d/james";
                owner = "james";
                group = "james";
                mode = "600";
                content = lib.concatStringsSep "\n" (map (authedKey: "${config.sops.placeholder."ssh/publicKeys/${authedKey}"}") authedKeys);
            };
        };
    };
    flake.modules.homeManager.framework-james = {...}: {
        imports = with self.modules.homeManager; [ssh];
        config = {
            programs.ssh = {
                enable = true;
                enableDefaultConfig = false;
                settings = {};
            };
        };
    };
}
