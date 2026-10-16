{self, ...}: {
    flake.modules.nixos.book.james = {...}: {
        imports = with self.modules.nixos; [
            # TODO: need to be importing some version of my user module
            hyprland
            docker
            gnome-keyring
        ];
        config = {
            my = {
                services.docker.groupUsers = ["james"];
            };
        };
    };
}
