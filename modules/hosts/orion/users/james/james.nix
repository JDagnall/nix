{
    self,
    lib,
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
            home-manager-interface
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
    flake.modules.homeManager.orion-james = {...}: {
        imports = with self.modules.homeManager; [
            james-headless

            stylix
            sops

            # CLI
            gh-cli
            nix-index
            btop
        ];
        config = {
            home.stateVersion = "25.11"; # Please read the comment before changing.
            my = {
                cli-tools.nixLoki.theme = "tinted-nvim";
            };
            # these will break things on a headless device, should probably check
            # the device profile in the stylix module but for now I am doing this
            stylix = {
                targets = {
                    gtk.enable = lib.mkForce false;
                    qt.enable = lib.mkForce false;
                };
            };
        };
    };
}
