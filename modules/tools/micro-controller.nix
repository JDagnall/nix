{
    pkgs,
    lib,
    config,
    ...
}: {
    options = {
        tools.micro-controller.platformio.enableUdev = lib.mkEnableOption "Enable udev rules for platformio";
    };
    config = let
        enableUdev = config.tools.micro-controller.platformio.enableUdev;
    in {
        services.udev.packages = with pkgs;
            lib.mkIf enableUdev [
                platformio-core.udev
                openocd
            ];
        users.groups."plugdev" = lib.mkIf enableUdev {};
        users.users."james".extraGroups = lib.mkIf enableUdev ["plugdev" "dialout"];
    };
}
