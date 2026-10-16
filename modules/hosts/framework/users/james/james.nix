{self, ...}: {
    flake.modules.nixos.framework.james = {...}: {
        imports = with self.modules.nixos; [
            hyprland
            gnome-keyring
            docker
            # TODO: need to be importing some version of my user config
        ];
        config = {
            my = {
                services.docker.groupUsers = ["james"];
            };
        };
    };
    # flake.modules.home.framework.james = {};
}
