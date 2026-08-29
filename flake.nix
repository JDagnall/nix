{
    description = "james' flake";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        nixos-hardware = {
            url = "github:/nixos/nixos-hardware/master";
        };
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixLoki = {
            url = "github:JDagnall/nixLoki";
            # url = "path:/home/james/repo/nixLoki";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        stylix = {
            url = "github:nix-community/stylix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixos-wsl = {
            url = "github:nix-community/NixOS-WSL";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nix-minecraft = {
            url = "github:Infinidoge/nix-minecraft";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # TODO: noctalia has been added to nixpkgs unstable and home-manager unstable
        # so the next time both are updated this can go
        noctalia = {
            url = "github:noctalia-dev/noctalia/refs/tags/v5.0.0-beta.9";
            # inputs.nixpkgs.follows = "nixpkgs"; # not doing this because it causes cachix misses
        };
        hyprland = {
            url = "github:hyprwm/Hyprland/refs/tags/v0.56.1";
            # inputs.nixpkgs.follows = "nixpkgs"; # apparently this doesn't work
        };
        direnv-instant = {
            url = "github:Mic92/direnv-instant";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nix-index-database = {
            url = "github:nix-community/nix-index-database";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        pia-tools = {
            url = "github:jdelkins/pia-tools";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        # plasma-manager = {
        # 	url = "github:nix-community/plasma-manager";
        # 	inputs.nixpkgs.follows = "nixpkgs";
        # 	inputs.home-manager.follows = "home-manager";
        # };
    };
    outputs = {
        nixpkgs,
        home-manager,
        # nixLoki,
        nixos-wsl,
        ...
    } @ inputs: let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
            inherit system;
            config = {
                # allows unfree in home-manager.
                allowUnfree = true;
            };
        };
        mkHomeManagerArgs = host: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
                inherit system;
                inherit inputs;
                inherit pkgs; # makes sure to inherit overlays like nixLoki
            };
            home-manager.users.james.imports = [
                ./hosts/${host}/home.nix
            ];
        };
        specialArgs = {
            inherit system;
            inherit inputs;
        };
    in {
        # nixos entrypoints
        nixosConfigurations = {
            framework = nixpkgs.lib.nixosSystem {
                inherit specialArgs;
                modules = [
                    ./hosts/framework/config.nix
                    home-manager.nixosModules.home-manager
                    (mkHomeManagerArgs "framework")
                ];
            };
            pc = nixpkgs.lib.nixosSystem {
                inherit specialArgs;
                modules = [
                    ./hosts/pc/config.nix
                    home-manager.nixosModules.home-manager
                    (mkHomeManagerArgs "pc")
                ];
            };
            mini = nixpkgs.lib.nixosSystem {
                inherit specialArgs;
                modules = [
                    ./hosts/mini/config.nix
                    home-manager.nixosModules.home-manager
                    (mkHomeManagerArgs "mini")
                ];
            };
            book = nixpkgs.lib.nixosSystem {
                inherit specialArgs;
                modules = [
                    ./hosts/book/config.nix
                    home-manager.nixosModules.home-manager
                    (mkHomeManagerArgs "book")
                ];
            };
            orion = nixpkgs.lib.nixosSystem {
                inherit specialArgs;
                modules = [
                    ./hosts/orion/config.nix
                    home-manager.nixosModules.home-manager
                    (mkHomeManagerArgs "orion")
                ];
            };
            wsl = nixpkgs.lib.nixosSystem {
                inherit specialArgs;
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
                    home-manager.nixosModules.home-manager
                    (mkHomeManagerArgs "wsl")
                ];
            };
        };
    };
}
