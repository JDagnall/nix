{self, ...}: {
    flake.modules.homeManager.swayosd = {...}: {
        imports = with self.modules.homeManager; [desktop];
        config = let
            # desktopCfg = config.my.desktop;
        in {
            my.desktop = {
                osd = "swayosd";
            };
            services.swayosd = {
                enable = true;
                topMargin = 0.1; # 10% down from top
            };
        };
    };
}
