{
    self,
    lib,
    ...
}: {
    # options for enabling this wierdly aren't in home-manager
    flake.modules.nixos.xfce = {...}: {
        services.xserver.desktopManager.xfce = {
            enable = true;
            enableWaylandSession = true;
            enableScreensaver = true;
        };
    };

    # TODO: need an interface pattern in nixos so that the home-manager module
    # can check if the nixos module is imported

    flake.modules.homeManager.xfce = {config, ...}: {
        imports = with self.modules.homeManager; [stylix-interface];
        config = {
            stylix.targets.xfce = lib.mkIf config.my.stylix.enabled {
                enable = true;
                fonts.enable = true;
            };
        };
    };
}
