{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.wsl = {pkgs, ...}: {
        imports = with self.modules.nixos; [stylix];
        config = {
            stylix = lib.mkForce {
                polarity = "dark"; # prefers dark theme
                base16Scheme = "${pkgs.base16-schemes}/..."; # TODO: pick a theme
                override = {};

                fonts = {
                    # define font sizes in differnet contexts. In points, 72 per inch
                    sizes = {
                        applications = 12;
                        desktop = 10;
                        popups = 12;
                        terminal = 12;
                    };
                };
            };
        };
    };
}
