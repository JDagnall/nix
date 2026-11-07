{
    self,
    lib,
    inputs,
    ...
}: {
    flake.modules.nixos.dagath = {pkgs, ...}: {
        imports = with self.modules.nixos; [
            base
            device

            noctalia-greeter
            sops
            ssh
            network
            pipewire
            avahi
            pia-openvpn
            bluetooth

            # USERS
            dagath-james
        ];
        config = {
            # config ------------------------------
            my = {
                hardware.device.profile = "laptop";
                hardware.network.physicalInterfaces = ["wlp3s0"];
            };

            # config ------------------------------

            # one liner NixOs options
            networking.hostName = "dagath";
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

            # touchscreen
            services.iptsd = {
                enable = true;
                config = {
                    Stylus.Disable = true;
                    Touchscreen.DisableOnPalm = true;
                };
            };
        };
    };
    flake.nixosConfigurations.dagath = inputs.nixpkgs.lib.nixosSystem {
        modules = [self.modules.nixos.dagath];
    };
}
