{lib, ...}: {
    flake.modules.nixos.micro-controller = {
        pkgs,
        config,
        ...
    }: {
        options = {
            my.services.micro-controller = {
                udevGroupMembers = lib.mkOption {
                    type = with lib.types; listOf str;
                    default = [];
                    description = "Users to be added to the plugdev and dialout groups for access to direct usb bus writes.";
                };
            };
        };
        config = let
            cfg = config.my.services.micro-controller;
        in {
            services.udev.packages = with pkgs; [
                platformio-core.udev
                openocd
            ];
            users.groups."plugdev".members = cfg.udevGroupMembers;
            users.groups."dialout".members = cfg.udevGroupMembers;
        };
    };
}
