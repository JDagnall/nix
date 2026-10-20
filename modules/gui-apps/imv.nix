{...}: {
    flake.modules.homeManager.imv = {...}: {
        config = {
            programs.imv = {
                enable = true;
                settings = {
                    options = {
                        overlay = true;
                    };
                };
            };
        };
    };
}
