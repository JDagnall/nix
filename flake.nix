{
    description = "James' flake";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        flake-parts.url = "github:hercules-ci/flake-parts";
        import-tree.url = "github:denful/import-tree";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        secrets = {
            flake = false;
            url = "path:./secrets";
        };
        wallpapers = {
            flake = false;
            url = "path:./wallpapers";
        };
        nixos-hardware = {
            url = "github:/nixos/nixos-hardware/master";
        };
        disko = {
            url = "github:nix-community/disko/latest";
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
        nix-minecraft = {
            url = "github:Infinidoge/nix-minecraft";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        # hyprland = {
        #     url = "github:hyprwm/Hyprland/refs/tags/v0.56.2";
        #     # inputs.nixpkgs.follows = "nixpkgs"; # apparently this doesn't work
        # };
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
    outputs = inputs:
        inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}
