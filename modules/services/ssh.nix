{inputs, ...}: {
    flake.modules.nixos.ssh = {config, ...}: {
        sops.secrets = let
            host = config.networking.hostName;
            sopsFile = "${inputs.secrets}/${host}/ssh.yaml";
        in {
            "ssh/root/private" = {
                sopsFile = sopsFile;
                path = "/etc/ssh/ssh_host_ed25519_key";
            };
            "ssh/root/public" = {
                sopsFile = sopsFile;
                path = "/etc/ssh/ssh_host_ed25519_key.pub";
            };
        };
        services.openssh = {
            enable = true;
            settings = {
                PasswordAuthentication = false;
                PermitRootLogin = "no";
            };
        };
    };
}
