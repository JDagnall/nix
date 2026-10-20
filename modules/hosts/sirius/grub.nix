{...}: {
    flake.modules.nixos.sirius = {...}: {
        # imports = []; # would import grub here if I was currently using it
        config = {
            boot.loader.grub.extraEntries = ''
                menuentry 'Windows' {
                    search --fs-uuid --no-floppy --set=root 063D-CA76
                    chainloader ($\{root})/efi/Microsoft/Boot/bootmgfw.efi
                }
            '';
        };
    };
}
