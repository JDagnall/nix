{
    self,
    lib,
    inputs,
    ...
}: {
    flake.modules.nixos.wsl = {pkgs, ...}: {
        imports = with self.modules.nixos; [
            inputs.nixos-wsl.nixosModules.default # wsl compat

            base
            device
            docker

            # USERS
            wsl-james
        ];
        config = {
            # My Config ------------------------------------------------------
            my = {
                hardware.device.profile = "headless";
            };

            # One Liner NixOs options ----------------------------------------
            wsl = {
                enable = true;
                defaultUser = "james";
                docker-desktop.enable = true;
            };
            # nix on wsl seems to need this for some reason
            programs.dconf.enable = true;
            networking.hostName = "wsl";
            time.timeZone = "Australia/Brisbane";
            # use latest linux kernal
            boot.kernelPackages = pkgs.linuxPackages_latest;
            system.stateVersion = "25.05"; # Did you read the comment?
            nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        };
    };
    flake.nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
        modules = [self.modules.nixos.wsl];
    };
}
