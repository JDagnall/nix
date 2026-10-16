{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.orion = {pkgs, ...}: {
        imports = with self.modules.nixos; [stylix];
        # host specific stylix
        config = {
            stylix = lib.mkForce {
                base16Scheme = "${pkgs.base16-schemes}/share/themes/black-metal.yaml";
                polarity = "dark"; # prefers dark theme
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
