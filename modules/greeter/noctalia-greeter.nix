{lib, ...}: {
    flake.modules.nixos.noctalia-greeter = {config, ...}: let
    in {
        services.greeter.noctalia-greeter = {
            enable = true;
            # package = ;
            cursorTheme = lib.mkIf config.stylix.enableConfig {
                name = config.stylix.cursor.name;
                package = config.stylix.cursor.package;
            };
            # extraArgs = [];
            settings = {
                cursor.size = lib.mkIf config.stylix.enableConfig config.stylix.cursor.size;
            };
        };
        # noctalia-greeter wants this to grab avatar pictures etc, really probably all
        # greeters want this?
        # TODO: maybe add this to a display-manager/greeter default config.
        services.accounts-daemon.enable = true;
    };
}
