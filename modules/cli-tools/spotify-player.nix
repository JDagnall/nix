{self, ...}: {
    flake.modules.homeManager.spotify-player = {config, ...}: {
        imports = with self.modules.homeManager; [stylix-interface];
        config = {
            programs.spotify-player = {
                enable = true;
                settings = {};
            };
            stylix.targets.spotify-player.enable = config.my.stylix.enabled;
        };
    };
}
