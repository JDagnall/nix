{
    self,
    inputs,
    ...
}: {
    flake.modules.nixos.book = {pkgs, ...}: {
        imports = with self.modules.nixos; [
            grub
            noctalia-greeter
            sops
            pipewire
            avahi
            pia-openvpn
            bluetooth

            # USERS
            book.james
        ];
        config = {
            # config ------------------------------
            my = {
                network.physicalInterfaces = ["wlp3s0"];
            };

            # config ------------------------------

            # one liner NixOs options
            networking.hostName = "book";
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
    flake.nixosConfigurations.book = inputs.nixpkgs.lib.nixosSystem {
        modules = [self.modules.nixos.book];
    };
}
