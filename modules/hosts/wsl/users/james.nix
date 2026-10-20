{self, ...}: {
    flake.modules.nixos.wsl-james = {
        pkgs,
        config,
        ...
    }: {
        imports = with self.modules.nixos; [
            james
        ];
        # config = {
        #     my = {
        #     };
        # };
    };
    flake.modules.homeManager.wsl-james = {pkgs, ...}: {
        imports = with self.modules.homeManager; [
            james-headless

            stylix
        ];
        config = {
            home.stateVersion = "25.05"; # Please read the comment before changing.
        };
    };
}
