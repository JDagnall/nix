{
    self,
    inputs,
    ...
}: {
    flake.modules.nixos.mini = {pkgs, ...}: {
        imports = with self.modules.nixos; [
            systemd-boot
            sops
            ssh
            avahi
            tailscale

            # USERS
            mini.james
        ];
        config = {
            # my configs -----------------------------------------------------
            my = {
                network.physicalInterfaces = []; # TODO: gotta check the interface name
                services.tailscale = {
                    tailnet = "stonecat-barometric";
                };
            };

            # One liner NixOs options ----------------------------------------
            networking.hostName = "mini";
            time.timeZone = "Australia/Brisbane";
            boot.kernelPackages = pkgs.linuxPackages_latest; # use latest linux kernal
            system.stateVersion = "25.05"; # Did you read the comment?
            networking.networkmanager.enable = true;
        };
    };
    flake.nixosConfigurations.mini = inputs.nixpkgs.lib.nixosSystem {
        modules = [self.modules.nixos.mini];
    };
}
