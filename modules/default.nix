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
}
