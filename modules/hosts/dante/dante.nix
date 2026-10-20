{
    self,
    inputs,
    ...
}: {
    flake.modules.nixos.dante = {pkgs, ...}: {
        imports = with self.modules.nixos; [
            base
            device

            grub
            noctalia-greeter
            sops
            network
            pipewire
            avahi
            pia-openvpn
            bluetooth

            # USERS
            dante-james
        ];
        config = {
            # config ------------------------------
            my = {
                hardware.device.profile = "laptop";
                hardware.network.physicalInterfaces = ["wlp3s0"];
            };

            # config ------------------------------

            # one liner NixOs options
            networking.hostName = "dante";
            boot.kernelPackages = pkgs.linuxPackages_latest; # use latest linux kernal
            system.stateVersion = "25.11"; # Did you read the comment?
            time.timeZone = "Australia/Brisbane";

            security.polkit.enable = true;
            networking.networkmanager.enable = true;
            # dont power of on power key press
            services.logind.settings.Login = {
                HandlePowerKey = "ignore";
            };
            # battery managment
            services.upower.enable = true;
            services.power-profiles-daemon.enable = true;
            services.blueman.enable = true; # bt manager software
            services.flatpak.enable = true;
        };
    };
    flake.nixosConfigurations.dante = inputs.nixpkgs.lib.nixosSystem {
        modules = [self.modules.nixos.dante];
    };
}
