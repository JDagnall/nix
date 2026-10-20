{
    self,
    inputs,
    ...
}: {
    flake.modules.nixos.framework-james = {pkgs, ...}: {
        imports = with self.modules.nixos; [
            james
            hyprland
            inputs.home-manager.nixosModules.home-manager
        ];
        config = {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
                # inherit system;
                inherit inputs;
                inherit pkgs; # makes sure to inherit overlays like nixLoki
            };
            home-manager.users.james.imports = [
                self.modules.homeManager.framework-james
            ];
            my = {
                allowedUnfreePkgNames = [
                    "spotify"
                    "slack"
                    "obsidian"
                ];
            };
        };
    };
    flake.modules.homeManager.framework-james = {pkgs, ...}: {
        imports = with self.modules.homeManager; [
            james-full

            sops
            stylix

            # CLI
            gh-cli
            nix-index

            # GUI
            obsidian
            libresuite
        ];
        config = {
            home.stateVersion = "25.05"; # Please read the comment before changing.
            home.packages = with pkgs; [
                # CLI
                cloc
                btop
                gzip
                nmap
                hwinfo
                lshw

                # GUI
                vlc
                zotero
                freetube
                slack
                vesktop
                spotify
            ];
        };
    };
}
