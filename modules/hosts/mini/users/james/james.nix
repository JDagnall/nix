{
    self,
    inputs,
    ...
}: {
    flake.modules.nixos.mini-james = {pkgs, ...}: {
        imports = with self.modules.nixos; [
            james
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
                self.modules.homeManager.mini-james
            ];
            # my = {};
        };
    };
    flake.modules.homeManager.mini-james = {pkgs, ...}: {
        imports = with self.modules.homeManager; [
            james-headless
        ];
        config = {
            home.stateVersion = "25.05"; # Please read the comment before changing.
            home.packages = with pkgs; [];
        };
    };
}
