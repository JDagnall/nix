{inputs, ...}: {
    flake.modules.nixos.sops = {
        pkgs,
        config,
        ...
    }: {
        # doesn't actually need it but if a module is importing outside modules
        # there should probably be a key just in case.
        key = "my/nixos/sops";
        imports = [
            inputs.sops-nix.nixosModules.sops
        ];
        config = let
            host = config.networking.hostName;
        in {
            environment.systemPackages = with pkgs; [sops];
            sops = {
                defaultSopsFormat = "yaml";
                defaultSopsFile = ./secrets/${host}/general.yaml;
                # defaultSopsKey = /var/sops/age/keys.txt;
                validateSopsFiles = true;
                age = {
                    keyFile = "/var/sops/age/key.txt";
                    # sshKeyPaths =
                };
            };
        };
    };
    flake.modules.homeManager.sops = {
        pkgs,
        config,
        osConfig,
        ...
    }: {
        # doesn't actually need it but if a module is importing outside modules
        # there should probably be a key just in case.
        key = "my/home/sops";
        imports = [
            inputs.sops-nix.homeManagerModules.sops
        ];
        config = let
            host = osConfig.networking.hostName;
        in {
            home.packages = with pkgs; [sops];
            sops = {
                defaultSopsFormat = "yaml";
                defaultSopsFile = ./secrets/${host}/general.yaml;
                # defaultSopsKey = /var/sops/age/keys.txt;
                validateSopsFiles = true;
                age = {
                    keyFile = "/home/${config.home.username}/.config/sops/age/key.txt";
                    # sshKeyPaths =
                };
            };
        };
    };
}
