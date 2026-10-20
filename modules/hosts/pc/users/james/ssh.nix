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
                "ssh/publicKeys/james/pc" = {
                    sopsFile = "${inputs.secrets}/common/ssh.yaml";
                };
            };
        };
    };
    flake.modules.nixos.pc-james = {config, ...}: {
        imports = with self.modules.nixos; [sops ssh];
        config = {
            sops.templates."ssh-james-authorizedKeys" = let
                authedKeys = ["james/framework" "james/book"];
            in {
                path = "/etc/ssh/authorized_keys.d/james";
                owner = "james";
                group = "james";
                mode = "600";
                content = lib.concatStringsSep "\n" (map (host: "${config.sops.placeholder."ssh/publicKeys/${host}"}") authedKeys);
            };
        };
    };
    flake.modules.homeManager.pc-james = {...}: {
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
