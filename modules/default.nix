{...}: {
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
    config = {
        # TEMPORARY, there just isn't anywhere else to put this atm
        # dendritic would fix this
        # add noctalia cachix so it doesn't have to build
        nix.settings = {
            extra-substituters = ["https://noctalia.cachix.org"];
            extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
        };
    };
}
