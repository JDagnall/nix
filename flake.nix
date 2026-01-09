{
	description = "james' flake";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
		home-manager = {
			url = "github:nix-community/home-manager/release-25.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nixLoki = {
			url = "github:JDagnall/nixLoki";
			# url = "path:/home/james/nixLoki";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		stylix = {
			url = "github:nix-community/stylix/release-25.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nixos-wsl = {
			url = "github:nix-community/NixOS-WSL/release-25.11";
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
		plasma-manager = {
			url = "github:nix-community/plasma-manager";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.home-manager.follows = "home-manager";
		};
	};

	outputs = {
		nixpkgs,
		home-manager,
		nixLoki,
		stylix,
		nixos-wsl,
		sops-nix,
		nix-minecraft,
		plasma-manager,
		...
	} @ inputs: let
		system = "x86_64-linux";
		pkgs =
			import nixpkgs {
				inherit system;
				config = {
					# allows unfree in home-manager.
					allowUnfree = true;
				};
				overlays = [
					nixLoki.overlays.default
					nixLoki.overlays.testNixLoki
				];
			};
	in {
		# nixos entrypoints
		nixosConfigurations = {
			virtualbox =
				nixpkgs.lib.nixosSystem {
					specialArgs = {inherit system;};
					modules = [./hosts/virtualbox/config.nix];
				};
			framework =
				nixpkgs.lib.nixosSystem {
					specialArgs = {inherit system;};
					modules = [
						./hosts/framework/config.nix
						stylix.nixosModules.stylix
						sops-nix.nixosModules.sops
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
						nix-minecraft.nixosModules.minecraft-servers
						{
							nixpkgs.overlays = [nix-minecraft.overlay];
						}
					];
				};
			pc =
				nixpkgs.lib.nixosSystem {
					specialArgs = {inherit system;};
					modules = [
						./hosts/pc/config.nix
						stylix.nixosModules.stylix
						sops-nix.nixosModules.sops
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
								./hosts/pc/home.nix
							];
						}
						nix-minecraft.nixosModules.minecraft-servers
						{
							nixpkgs.overlays = [nix-minecraft.overlay];
						}
					];
				};
			mini =
				nixpkgs.lib.nixosSystem {
					specialArgs = {inherit system;};
					modules = [
						./hosts/mini/config.nix
						stylix.nixosModules.stylix
						sops-nix.nixosModules.sops
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
								./hosts/mini/home.nix
							];
						}
						nix-minecraft.nixosModules.minecraft-servers
						{
							nixpkgs.overlays = [nix-minecraft.overlay];
						}
					];
				};
			book =
				nixpkgs.lib.nixosSystem {
					specialArgs = {inherit system;};
					modules = [
						./hosts/book/config.nix
						stylix.nixosModules.stylix
						sops-nix.nixosModules.sops
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
							# home-manager.backupFileExtension = "old";
							home-manager.users.james.imports = [
								./hosts/book/home.nix
							];
							home-manager.sharedModules = [plasma-manager.homeModules.plasma-manager];
						}
						nix-minecraft.nixosModules.minecraft-servers
						{
							nixpkgs.overlays = [nix-minecraft.overlay];
						}
					];
				};
			wsl =
				nixpkgs.lib.nixosSystem {
					specialArgs = {inherit system;};
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
						nix-minecraft.nixosModules.minecraft-servers
						{
							nixpkgs.overlays = [nix-minecraft.overlay];
						}
					];
				};
		};
	};
}
