# interface options about the general nature of the device
{lib, ...}: let
in {
    flake.modules.nixos.device = {
        key = "my/nixos/device";
        options = {
            my.hardware.device = {
                profile = lib.mkOption {
                    type = lib.types.enum ["headless" "laptop" "desktop"];
                    description = "The physical form factor of the device.";
                };
            };
        };
    };
}
