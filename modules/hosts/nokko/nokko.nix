{
    self,
    inputs,
    ...
}: {
    flake.modules.nixos.nokko = {pkgs, ...}: {
        imports = with self.modules.nixos; [
            base
            device

            systemd-boot
            sops
            network
            ssh
            avahi
            tailscale

            # USERS
            nokko-james
        ];
        config = {
            # my configs -----------------------------------------------------
            my = {
                hardware.device.profile = "headless";
                hardware.network.physicalInterfaces = []; # TODO: gotta check the interface name
                services.tailscale = {
                    tailnet = "stonecat-barometric";
                };
            };

            # One liner NixOs options ----------------------------------------
            networking.hostName = "nokko";
            time.timeZone = "Australia/Brisbane";
            boot.kernelPackages = pkgs.linuxPackages_latest; # use latest linux kernal
            system.stateVersion = "25.05"; # Did you read the comment?
            networking.networkmanager.enable = true;
        };
    };
    flake.nixosConfigurations.nokko = inputs.nixpkgs.lib.nixosSystem {
        modules = [self.modules.nixos.nokko];
    };
}
