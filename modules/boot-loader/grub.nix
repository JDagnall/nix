{
    lib,
    config,
    ...
}: {
    options = {
        boot-loader.grub = {
            enable = lib.mkEnableOption {
                default = false;
                description = "Enable grub boot loader";
            };
            host = lib.mkOption {
                type = lib.types.nullOr lib.types.string;
                default = null;
                description = "The hostname if it is relevant in order to specify host specific boot entries";
            };
        };
    };
    config = let
        pc_entries = ''
            menuentry 'Windows' {
                search --fs-uuid --no-floppy --set=root 063D-CA76
                chainloader ($\{root})/efi/Microsoft/Boot/bootmgfw.efi
            }

        '';
    in
        lib.mkIf config.boot-loader.grub.enable {
            boot.loader.timeout = null;
            boot.loader.grub = {
                enable = true;
                device = "nodev";
                efiSupport = true;
                useOSProber = false;
                fsIdentifier = "label";
                extraEntries =
                    ''
                        menuentry "Reboot" {
                            reboot
                        }
                        menuentry "Poweroff" {
                            halt
                        }
                    ''
                    + lib.optionalString (config.networking.hostName == "pc") pc_entries;
            };
            boot.loader.efi.canTouchEfiVariables = true;
            boot.loader.efi.efiSysMountPoint = "/boot";

            stylix.targets.grub = lib.mkIf config.stylix.enableConfig {
                enable = true;
                useWallpaper = true;
            };
        };
}
