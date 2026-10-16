{...}: {
    flake.modules.nixos.bluetooth = {...}: {
        hardware.bluetooth = {
            enable = true;
            powerOnBoot = true; # turn bt device on
            settings = {
                General = {
                    Experimental = true; # Enables showing battery of bt devices
                };
            };
        };
    };
}
