{self, ...}: {
    flake.modules.homeManager.mako = {config, ...}: {
        imports = with self.modules.homeManager; [desktop stylix-interface];
        config = {
            my.desktop = {
                notificationManager = "mako";
            };
            services.mako = {
                enable = true;
                settings = {
                    anchor = "top-right";
                    default-timeout = 2000; # ms
                    ignore-timeout = 1; # always use default-timeout
                    border-radius = "10,10,10,10";
                };
            };
            stylix.targets.mako.enable = config.my.stylix.enabled;
        };
    };
}
