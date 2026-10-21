{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.noctalia-greeter = {config, ...}: let
    in {
        imports = with self.modules.nixos; [stylix-interface];
        config = {
            services.displayManager.noctalia-greeter = {
                enable = true;
                # package = ;
                cursorTheme = lib.mkIf config.my.stylix.enabled {
                    name = config.stylix.cursor.name;
                    package = config.stylix.cursor.package;
                };
                # extraArgs = [];
                settings = lib.mkIf config.my.stylix.enabled {
                    cursor.size = config.stylix.cursor.size;
                };
            };
            # noctalia-greeter wants this to grab avatar pictures etc, really probably all
            # greeters want this?
            # TODO: maybe add this to a display-manager/greeter default config.
            services.accounts-daemon.enable = true;
        };
    };
}
