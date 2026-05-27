{
    pkgs,
    lib,
    config,
    inputs,
    ...
}: {
    imports = [
        inputs.sops-nix.nixosModules.sops
    ];
    options = {
        sops.enable = lib.mkEnableOption "Enable sops secret management.";
    };
    config = let
        host = config.networking.hostName;
    in
        lib.mkIf config.sops.enable {
            environment.systemPackages = with pkgs; [sops];
            sops = {
                defaultSopsFormat = "yaml";
                defaultSopsFile = ./secrets/${host}/general.yaml;
                # defaultSopsKey = /var/sops/age/keys.txt;
                validateSopsFiles = true;
                age = {
                    keyFile = "/home/james/.config/sops/age/keys.txt";
                    # sshKeyPaths =
                };
            };
        };
}
