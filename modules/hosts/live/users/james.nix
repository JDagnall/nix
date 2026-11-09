{
    self,
    lib,
    inputs,
    ...
}: {
    flake.modules.nixos.live-james = {pkgs, ...}: {
        imports = with self.modules.nixos; [
            inputs.home-manager.nixosModules.home-manager
            james
            home-manager-interface
            stylix-interface
            # sops
        ];
        config = {
            my.home-manager.enabled = true;
            home-manager.useUserPackages = true;
            home-manager.useGlobalPkgs = true;
            home-manager.extraSpecialArgs = {
                # inherit system;
                inherit inputs;
                inherit pkgs; # makes sure to inherit overlays like nixLoki
            };
            home-manager.users.james.imports = [
                self.modules.homeManager.live-james
            ];
        };
    };
    flake.modules.homeManager.live-james = {pkgs, ...}: {
        imports = with self.modules.homeManager; [
            james-headless
            sops
        ];
        config = {
            home.stateVersion = "25.05"; # Please read the comment before changing.
            home.packages = with pkgs; [
                gzip
                hwinfo
                lshw
            ];
            my = {
                cli-tools.nixLoki.theme = lib.mkForce "catppuccin";
            };
        };
    };
}
