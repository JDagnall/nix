{...}: {
    flake.modules.homeManager.nh = {...}: {
        config = {
            programs.nh = {
                enable = true;
                # supposedly better than nix-collect-garbage, but havent switched yet
                clean = {
                    enable = false;
                    dates = "weekly";
                    extraArgs = "--keep 5 --keep-since 3d";
                };
            };
        };
    };
}
