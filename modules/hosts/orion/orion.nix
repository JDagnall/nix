{
    self,
    inputs,
    ...
}: {
    flake.modules.nixos.orion = {pkgs, ...}: {
        imports = with self.modules.nixos; [
            systemd-boot
            sops
            msmtp
            avahi
            tailscale
            resolved
            pia-tools
            minecraft-servers

            # servers
            caddy
            scrutiny
            jellyfin
            qbittorrent
            sonarr
            radarr
            prowlarr
            flaresolverr
            seerr
            transmission
            immich

            # USERS
            orion.james
        ];
        config = {
            # my config options
            my = {
                network.physicalInterfaces = ["enp34s0"];
                tools.msmtp = {
                    accounts = {
                        gmail = {
                            host = "smtp.gmail.com";
                            auth = true;
                            user = "james.t.dagnall";
                            from = "james.t.dagnall@gmail.com";
                        };
                    };
                    defaultAccount = "gmail";
                    defaultAlias = {
                        to = "james.t.dagnall@gmail.com";
                    };
                };
                services.tailscale = {
                    interfacePatch = true;
                    tailnet = "stonecat-barometric";
                };
                servers.caddy.email = "james.t.dagnall@gmail.com";

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
}
