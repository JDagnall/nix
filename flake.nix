{
    description = "james' flake";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager/master";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixLoki = {
            url = "github:JDaggers/nixLoki";
            # url = "path:/home/james/nixLoki";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        stylix = {
            url = "github:nix-community/stylix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    };

    outputs =
        {
            nixpkgs,
            home-manager,
            nixLoki,
            stylix,
            nixos-wsl,
            ...
        }@inputs:
        let
            system = "x86_64-linux";
            pkgs = import nixpkgs {
                inherit system;
                config = {
                    allowUnfree = true;
                };
                overlays = [
                    nixLoki.overlays.default
                    nixLoki.overlays.testNixLoki
                ];
            };
        in
        {
            # nixos entrypoints
            nixosConfigurations = {
                virtualbox = nixpkgs.lib.nixosSystem {
                    specialArgs = { inherit system; };
                    modules = [ ./hosts/virtualbox/config.nix ];
                };
                framework = nixpkgs.lib.nixosSystem {
                    specialArgs = { inherit system; };
                    modules = [
                        ./hosts/framework/config.nix
                        stylix.nixosModules.stylix
                        # using home-manager as a nixos module here
                        home-manager.nixosModules.home-manager
                        {
                            home-manager.useGlobalPkgs = true;
                            home-manager.useUserPackages = true;
                            home-manager.extraSpecialArgs = {
                                inherit system;
                                inherit inputs;
                                inherit pkgs; # makes sure to inherit overlays like nixLoki
                            };
                            home-manager.users.james.imports = [
                                ./hosts/framework/home.nix
                            ];
                        }
                    ];
                };
                wsl = nixpkgs.lib.nixosSystem {
                    specialArgs = { inherit system; };
                    system = "x86_64-linux";
                    modules = [
                        nixos-wsl.nixosModules.default
                        {
                            system.stateVersion = "25.05";
                            wsl.enable = true;
                            wsl.defaultUser = "james";
                            wsl.docker-desktop.enable = true;
                        }
                        ./hosts/wsl/config.nix
                        stylix.nixosModules.stylix
                        # using home-manager as a nixos module here
                        home-manager.nixosModules.home-manager
                        {
                            home-manager.useGlobalPkgs = true;
                            home-manager.useUserPackages = true;
                            home-manager.extraSpecialArgs = {
                                inherit system;
                                inherit inputs;
                                inherit pkgs; # makes sure to inherit overlays like nixLoki
                            };
                            home-manager.users.james.imports = [
                                ./hosts/wsl/home.nix
                            ];
                        }
                    ];
                };
            };

        };
}
