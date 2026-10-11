{self, ...}: {
    flake.modules.nixos.gdm = {config, ...}: {
        imports = with self.modules.nixos; [stylix-interface];
        config = {
            services.greeter.gdm = {
                enable = true;
                debug = false;
                banner = "Hello There!"; # just greeting text
                autoSuspend = true;
            };
            stylix.targets.gnome.enable = config.my.stylix.enabled;
        };
    };
}
