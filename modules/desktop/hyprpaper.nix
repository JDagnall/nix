{
    self,
    lib,
    ...
}: {
    flake.modules.homeManager.hyprpaper = {config, ...}: {
        imports = with self.modules.homeManager; [desktop stylix-interface];
        config = let
            # cfg = config.my.desktop.hyprlock;
            desktopCfg = config.my.desktop;
        in {
            assertions = [
                {
                    assertion = desktopCfg.name == "hyprland";
                    message = ''
                        Hyprpaper cannot work without hyprland.
                        Please use enable hyprland or disable hyprpaper'';
                }
            ];
            my.desktop = {
                wallpaperProvider = "hyprpaper";
            };
            services.hyprpaper = {
                enable = true;
                settings = {
                    splash = false; # text
                    splash_offset = 1;
                    ipc = true; # allows hyprpaper to be controlled by hyprland
                };
            };
            stylix.targets.hyprpaper = lib.mkIf config.my.stylix.enabled {
                enable = true;
                image.enable = true;
            };
        };
    };
}
