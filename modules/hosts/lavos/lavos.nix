{
    self,
    inputs,
    ...
}: {
    flake.modules.nixos.lavos = {pkgs, ...}: {
        imports = with self.modules.nixos; [
            base
            device

            grub
            noctalia-greeter
            sops
            network
            pipewire
            pia-openvpn
            tailscale
            bluetooth

            # USERS
            lavos-james
        ];
        config = {
            # my options ------------------------------
            my = {
                hardware.device.profile = "laptop";
                hardware.network.physicalInterfaces = ["wlp6s0"];
                services.tailscale = {
                    interfacePatch = true;
                    tailnet = "stonecat-barometric";
                };
            };

            # One liner NixOs options ----------------------------------------
            networking.hostName = "lavos";
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
    flake.nixosConfigurations.lavos = inputs.nixpkgs.lib.nixosSystem {
        modules = [self.modules.nixos.lavos];
    };
}
