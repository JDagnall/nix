{
    self,
    inputs,
    ...
}: {
    flake.modules.nixos.ssh = {config, ...}: {
        imports = with self.modules.nixos; [sops];
        config = {
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
    };
    flake.modules.homeManager.ssh = {
        config,
        osConfig,
        ...
    }: {
        imports = with self.modules.homeManager; [sops];
        config = {
            sops.secrets = let
                host = osConfig.networking.hostName;
                user = config.home.username;
                homeDir = config.home.homeDirectory;
                sopsFile = "${inputs.secrets}/${host}/ssh.yaml";
            in {
                "ssh/${user}/private" = {
                    sopsFile = sopsFile;
                    # mode = 400;
                    path = "${homeDir}/.ssh/key";
                };
                "ssh/${user}/public" = {
                    sopsFile = sopsFile;
                    # mode = 400;
                    path = "${homeDir}/.ssh/key.pub";
                };
            };
        };
    };
}
