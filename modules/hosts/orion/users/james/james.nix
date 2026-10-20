{
    self,
    inputs,
    ...
}: {
    flake.modules.nixos.orion-james = {
        pkgs,
        config,
        ...
    }: {
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
                self.modules.homeManager.orion-james
            ];

            # so I can use 'sendmail'
            users.groups."msmtp".members = [config.users.groups."james".name];
            # add myself to the media group
            users.groups."media".members = ["james"];
            my.gaming.minecraft-servers = {
                groupMembers = ["james"];
            };
        };
    };
    flake.modules.homeManager.orion-james = {pkgs, ...}: {
        imports = with self.modules.homeManager; [
            james-headless

            stylix
            sops

            # CLI
            gh-cli
            nix-index
        ];
        config = {
            home.stateVersion = "25.11"; # Please read the comment before changing.
        };
    };
}
