{
    self,
    inputs,
    ...
}: {
    flake.modules.nixos.orion = {pkgs, ...}: {
        imports = with self.modules.nixos; [
            base
            device
            gpu

            systemd-boot
            sops
            avahi
            tailscale
            resolved
            pia-tools
            minecraft-servers

            # servers
            scrutiny
            jellyfin
            qbittorrent
            sonarr
            radarr
            prowlarr
            flaresolverr
            seerr
            immich

            # USERS
            orion-james
        ];
        config = {
            # my config options
            my = {
                hardware.device.profile = "headless";
                hardware.gpu.type = "nvidia";
                services.tailscale = {
                    interfacePatch = true;
                    tailnet = "stonecat-barometric";
                };
                services.vpn.torrentCon = {
                    portForward = true;
                };

                # TODO: should maybe go in user config
                gaming.minecraft-servers = {
                    "26.2" = true;
                };
            };

            # NixOs options, simple one line enable switched that don't need
            # to be modules
            networking.hostName = "orion";
            system.stateVersion = "25.11"; # Did you read the comment?
            time.timeZone = "Australia/Brisbane";
            # use latest linux kernal
            boot.kernelPackages = pkgs.linuxPackages_latest;

            # network manager is less suitable for servers
            networking.useNetworkd = true;
            systemd.network.enable = true;
            # allow wake on lan with magic packet for this computer
            networking.interfaces."enp34s0".wakeOnLan = {
                enable = true;
                policy = ["magic"];
            };
            # causes problems
            networking.enableIPv6 = false;
        };
    };
    flake.nixosConfigurations.orion = inputs.nixpkgs.lib.nixosSystem {
        modules = [self.modules.nixos.orion];
    };

    # flake.modules.homeManager.orion = {...}: {
    #     config = {
    #         my = {
    #         };
    #     };
    # };
}
