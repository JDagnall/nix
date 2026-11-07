{
    self,
    lib,
    inputs,
    ...
}: {
    flake.modules.nixos.dagath = {pkgs, ...}: {
        # host specific stylix
        imports = with self.modules.nixos; [stylix];
        config = {
            stylix = lib.mkForce {
                image = "${inputs.wallpapers}/monke_fire.png";
                polarity = "dark"; # prefers dark theme
                base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
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
