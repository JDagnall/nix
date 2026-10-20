{
    lib,
    self,
    ...
}: {
    flake.modules.homeManager.hyprlock = {
        pkgs,
        config,
        osConfig,
        ...
    }: {
        imports = with self.modules.homeManager; [desktop stylix-interface];
        config = let
            # cfg = config.my.desktop.hyprlock;
            desktopCfg = config.my.desktop;
        in {
            my.desktop = {
                lockScreen = let
                    hyprlock-bin = "${pkgs.hyprlock}/bin/hyprlock";
                in {
                    name = "hyprlock";
                    command = "pidof ${hyprlock-bin} || ${hyprlock-bin}";
                };
            };
            assertions = [
                {
                    assertion = desktopCfg.name == "hyprland";
                    message = ''
                        Hyprlock cannot work without hyprland.
                        Please use enable hyprland or disable hyprlock'';
                }
            ];
            programs.hyprlock = {
                enable = true;
                settings = {
                    general = {
                        hide_cursor = true;
                        ignore_empty_input = false;
                        immediate_render = true;
                        text_trim = true;
                    };
                    auth = {
                        pam = {
                            enabled = true;
                            # module = ;
                        };
                        # if fingerprint daemon is enabled
                        fingerprint = lib.mkIf osConfig.services.fprintd.enable {
                            enabled = true;
                            ready_message = "Scan fingerprint to unlock";
                            present_message = "Scanning fingerprint";
                            retry_delay = 250; # ms
                        };
                    };
                    animations = {
                        enabled = true;
                    };
                };
            };

            stylix.targets.hyprlock = lib.mkIf config.my.stylix.enabled {
                enable = true;
                useWallpaper = config.stylix.image != null;
            };
        };
    };
}
