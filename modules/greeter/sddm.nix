{...}: {
    flake.modules.nixos.sddm = {
        # pkgs,
        ...
    }: {
        # environment.systemPackages = with pkgs; [(catppuccin-sddm.override {flavor = "mocha";})];
        services.greeter.sddm = {
            enable = true;
            wayland.enable = true;
            # theme = "catppuccin-mocha";
            # package = pkgs.kdePackages.sddm;
            settings = {
                General = {
                    DisplayServer = "wayland"; # should be configured by option probably but whatevs
                };
            };
        };
    };
}
