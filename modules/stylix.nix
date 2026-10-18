{
    self,
    lib,
    inputs,
    ...
}: {
    flake.modules.nixos.stylix-interface = {...}: {
        key = "my/nixos/stylix-interface"; # intended to be imported many times
        options.my = {
            stylix = {
                enabled = lib.mkEnableOption "Stylix is enabled";
            };
        };
    };
    flake.modules.nixos.stylix = {pkgs, ...}: {
        # doesn't actually need it but if a module is importing outside modules
        # there should probably be a key just in case.
        key = "my/nixos/stylix";
        imports = [
            inputs.stylix.nixosModules.stylix
            self.modules.nixos.stylix-interface
        ];
        config = {
            my.stylix.enabled = true;
            stylix = {
                enable = true;
                # Adds stylix to all home-manager configs which are modules of this nix config
                homeManagerIntegration.autoImport = true;
                homeManagerIntegration.followSystem = true; # makes home-manager inherit this stylix config
                enableReleaseChecks = true; # ?
                autoEnable = false; # automatically turn on for all compatible programs
                # override theme colors
                override = {};
                imageScalingMode = "fill";
                cursor = {
                    name = "catppuccin-mocha-light-cursors";
                    package = pkgs.catppuccin-cursors.mochaLight;
                    size = 18;
                };
                fonts = {
                    serif = {
                        name = "NotoSans Nerd Font";
                        package = pkgs.dejavu_fonts;
                    };
                    sansSerif = {
                        name = "NotoSerif Nerd Font";
                        package = pkgs.dejavu_fonts;
                    };
                    monospace = {
                        name = "JetBrainsMono Nerd Font";
                        package = pkgs.nerd-fonts.jetbrains-mono;
                    };
                    emoji = {
                        name = "Noto Color Emoji"; # is default, there is a monochrome one too
                        package = pkgs.noto-fonts-color-emoji;
                    };
                    # define font sizes in differnet contexts. In points, 72 per inch
                    sizes = {
                        applications = 12;
                        desktop = 10;
                        popups = 10;
                        terminal = 10;
                    };
                };
                targets.font-packages.enable = true;
                targets.fontconfig = {
                    enable = true;
                    fonts.enable = true;
                };
                targets.console = {
                    enable = true;
                    colors.enable = true;
                };
                # supported apps for opacity is limited
                opacity = {
                    applications = 1.0;
                    desktop = 0.9;
                    popups = 0.9;
                    terminal = 0.9;
                };
            };
        };
    };
}
