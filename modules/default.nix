{
    lib,
    config,
    ...
}: {
    imports = [
        ./nvidia.nix
        ./evremap.nix
        ./window-manager
        ./display-manager
        ./boot-loader
        ./service
        ./gaming
        ./desktop-manager
        ./tools
    ];
    options = {
        allowedUnfreePkgNames = lib.mkOption {
            type = with lib.types; listOf str;
            default = [];
            description = "Allowed list of unfree pkg names, that will be allowed with the unfree predicate";
        };
    };
    config = {
        # TEMPORARY, there just isn't anywhere else to put this atm
        # dendritic would fix this
        # add noctalia cachix so it doesn't have to build
        nix.settings = {
            extra-substituters = ["https://noctalia.cachix.org"];
            extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
        };
        nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.allowedUnfreePkgNames;
    };
}
