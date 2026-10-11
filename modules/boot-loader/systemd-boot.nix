{...}: {
    flake.modules.nixos.systemd-boot = {...}: {
        boot.loader.systemd-boot = {
            enable = true;
            # for debugging, etc
            edk2-uefi-shell.enable = true;
        };
        boot.loader.efi.canTouchEfiVariables = true;
    };
}
