{
  description = "james' flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixLoki = {
      # TODO: change to github link
      url = "github:JDaggers/nixLoki";
      # url = "path:/home/james/nixLoki";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    # self,
    nixpkgs, home-manager, nixLoki, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
        overlays = [ nixLoki.overlays.default nixLoki.overlays.testNixLoki ];
      };
    in {
      # nixos entrypoints
      nixosConfigurations = {
        virtualbox = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit system; };
          modules = [ ./hosts/virtualbox/config.nix ];
        };
        framework = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit system; };
          modules = [ ./hosts/framework/config.nix ];
        };
      };

      # home-manager entrypoints
      homeConfigurations = {
        virtualbox = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit system;
            inherit inputs;
          };
          modules = [ ./hosts/virtualbox/home.nix ];
        };
        framework = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit system;
            inherit inputs;
          };
          modules = [ ./hosts/framework/home.nix ];
        };
      };
    };
}
