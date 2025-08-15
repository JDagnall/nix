{
    pkgs,
    lib,
    ...
}:
{
    options = {
        # enable is taken by stylix itself
        stylix.enableConfig = lib.mkEnableOption {
            default = false;
            description = "Enable any stylix theming";
        };
    };
    config = {
        stylix = {
            enable = true;
            # Adds stylix to all home-manager configs which are modules of this nix config
            # stylix.homeManagerIntegration.autoImport = true;
            # stylix.homeManagerIntegration.followSystem = true; # makes home-manager inherit this stylix config
            enableReleaseChecks = true; # ?
            autoEnable = false; # automatically turn on for all compatible programs
            base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
            # override theme colors
            override = { };
            polarity = "dark"; # prefers dark theme
            image = ./wallpapers/A_feverish_Little_Fox_Caldecot.png; # wallpaper, can opt to have theme derived from it
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
                    name = "JetBrainsMono Nerd Font Mono";
                    package = pkgs.nerd-fonts.jetbrains-mono;
                };
                emoji = {
                    name = "Noto Color Emoji"; # is default, there is a monochrome one too
                    package = pkgs.noto-fonts-color-emoji;
                };
                # other font packages to install
                packages = [
                    pkgs.nerd-fonts.victor-mono
                    pkgs.nerd-fonts.fira-code
                    pkgs.nerd-fonts.jetbrains-mono
                    pkgs.nerd-fonts.noto
                ];
                # define font sizes in differnet contexts. In points, 72 per inch
                sizes = {
                    applications = 12;
                    desktop = 10;
                    popups = 10;
                    terminal = 10;
                };
            };
            # supported apps for opacity is limited
            opacity = {
                applications = 1.0;
                desktop = 1.0;
                popups = 1.0;
                terminal = 0.9;
            };
        };
    };
}
