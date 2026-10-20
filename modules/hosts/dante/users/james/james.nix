{
    self,
    inputs,
    ...
}: {
    flake.modules.nixos.dante-james = {pkgs, ...}: {
        imports = with self.modules.nixos; [
            james
            hyprland
            inputs.home-manager.nixosModules.home-manager
        ];
        config = {
            home-manager.useUserPackages = true;
            home-manager.useGlobalPkgs = true;
            home-manager.extraSpecialArgs = {
                # inherit system;
                inherit inputs;
                inherit pkgs; # makes sure to inherit overlays like nixLoki
            };
            home-manager.users.james.imports = [
                self.modules.homeManager.dante-james
            ];
            my = {
                allowedUnfreePkgNames = [
                    "spotify"
                ];
            };
        };
    };
    flake.modules.homeManager.dante-james = {pkgs, ...}: {
        imports = with self.modules.homeManager; [
            james-full

            sops
            stylix
        ];
        config = {
            home.stateVersion = "25.11"; # Please read the comment before changing.
            home.packages = with pkgs; [
                # CLI

                # GUI
                vlc
                freetube
                spotify
                jellyfin-desktop
            ];

            my = {
                desktop = {
                    hyprland.touchpadSwipe.enable = true;
                };
            };
            programs.brave.enable = true;
        };
    };
}
