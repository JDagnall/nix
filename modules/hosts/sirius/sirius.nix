{
    self,
    inputs,
    ...
}: {
    flake.modules.nixos.sirius = {...}: {
        imports = with self.modules.nixos; [
            base
            device
            gpu

            systemd-boot
            noctalia-greeter
            sops
            network
            avahi
            bluetooth
            pipewire
            tailscale

            # USERS
            sirius-james
        ];
        config = {
            networking.hostName = "sirius";
            time.timeZone = "Australia/Brisbane";
            system.stateVersion = "25.05"; # Did you read the comment?

            # config options set by me
            my = {
                hardware.device.profile = "desktop";
                hardware.gpu.type = "amd";
                hardware.network.physicalInterfaces = ["enp7s0" "wlp6s0"];
                services.tailscale = {
                    interfacePatch = true;
                    tailnet = "stonecat-barometric";
                };
            };

            # NixOs options, simple one line enable switched that don't need
            # to be modules
            security.polkit.enable = true;
            networking.networkmanager.enable = true;
            # bt manager software
            services.blueman.enable = true;
            # CUPS for network printing
            services.printing.enable = true;
            services.printing.browsed.enable = true; # auto discovery
            services.flatpak.enable = true;
        };
    };
    # flake.modules.homeManager.sirius = {
    #     ...
    # }: {
    #     config = {
    #         my = {
    #         };
    #     };
    # };

    flake.nixosConfigurations.sirius = inputs.nixpkgs.lib.nixosSystem {
        modules = [self.modules.nixos.sirius];
    };
}
