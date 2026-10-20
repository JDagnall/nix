{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.grub = {config, ...}: {
        imports = with self.modules.nixos; [stylix-interface];
        config = {
            boot.loader.timeout = null;
            boot.loader.grub = {
                enable = true;
                device = "nodev";
                efiSupport = true;
                useOSProber = false;
                fsIdentifier = "label";
                extraEntries = ''
                    menuentry "Reboot" {
                        reboot
                    }
                    menuentry "Poweroff" {
                        halt
                    }
                '';
            };
            boot.loader.efi.canTouchEfiVariables = true;
            boot.loader.efi.efiSysMountPoint = "/boot";

            stylix.targets.grub = lib.mkIf config.my.stylix.enabled {
                enable = true;
                useWallpaper = true;
            };
        };
    };
}
