{
    self,
    lib,
    ...
}: {
    flake.modules.homeManager.mangohud = {config, ...}: {
        imports = with self.modules.homeManager; [stylix-interface];
        config = {
            programs.mangohud = {
                enable = true;
                enableSessionWide = true;
                settings = {
                    # legacy_layout = 2;
                    gpu_list = [0];
                    gpu_temp = true;
                    cpu_temp = true;
                    cpu_load = true;
                    vram = true;
                    ram = true;
                    fps = true;
                    frame_timing = 0;
                    wine = true;

                    hud_compact = true;
                    height = 100;
                    round_corners = 2;
                    horizontal = true;
                    horizontal_stretch = 0;
                    # override some of stylix's bad decisions
                    background_alpha = lib.mkForce 0.5;
                    alpha = lib.mkForce 0.8;
                };
                settingsPerApplication = {};
            };
            stylix.targets.mangohud.enable = config.my.stylix.enabled;
        };
    };
}
