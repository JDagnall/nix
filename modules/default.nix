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
        ./network.nix
        ./desktop-manager
        ./tools
    ];
    options = {
        allowedUnfreePkgNames = lib.mkOption {
            type = with lib.types; listOf str;
            default = [];
            description = "Allowed list of unfree pkg names, that will be allowed with the unfree predicate";
        };
        allowedUnfreePkgPredicates = lib.mkOption {
            type = with lib.types; listOf (functionTo bool);
            default = [];
            description = ''
                Predicate functions which accept a pkg as an input.
                If any of them return true the pkg is accepted.
            '';
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
        # predicate that allows any pkg names in allowedUnfreePkgNames
        allowedUnfreePkgPredicates = [
            (pkg: builtins.elem (lib.getName pkg) config.allowedUnfreePkgNames)
        ];
        # runs pred(pkg) for each pred, if any return true the predicate is true
        nixpkgs.config.allowUnfreePredicate = pkg: lib.any (pred: pred pkg) config.allowedUnfreePkgPredicates;
    };
}
