{
    self,
    inputs,
    ...
}: {
    flake.modules.nixos.framework = {pkgs, ...}: {
        imports = with self.modules.nixos; [
            default
            grub
            noctalia-greeter
            sops
            network
            pipewire
            pia-openvpn
            tailscale
            bluetooth

            # USERS
            framework-james
        ];
        config = {
            # my options ------------------------------
            my = {
                network.physicalInterfaces = ["wlp6s0"];
                services.tailscale = {
                    interfacePatch = true;
                    tailnet = "stonecat-barometric";
                };
            };

            # One liner NixOs options ----------------------------------------
            networking.hostName = "framework";
            # time.timeZone = "Australia/Brisbane";
            services.automatic-timezoned.enable = true;
            # use latest linux kernal
            boot.kernelPackages = pkgs.linuxPackages_latest;
            system.stateVersion = "25.05"; # Did you read the comment?

            networking.networkmanager.enable = true;
            security.polkit.enable = true;
            services.fprintd.enable = true;
            services.blueman.enable = true; # bt manager software
            services.upower.enable = true; # power management
            services.power-profiles-daemon.enable = true;
            # dont power of on key press
            # services.logind.settings.Login = {HandlePowerKey = "ignore";};
            services.flatpak.enable = true;
        };
    };
    flake.nixosConfigurations.framework = inputs.nixpkgs.lib.nixosSystem {
        modules = [self.modules.nixos.framework];
    };
}
