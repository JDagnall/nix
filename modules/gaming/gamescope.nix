{...}: {
    flake.modules.nixos.gamescope = {...}: {
        programs.gamescope = {
            enable = true;
            capSysNice = true;
            env = {};
            args = [
                "--mangoapp"
                "--expose-wayland"
            ];
        };
    };
}
