{self, ...}: {
    flake.modules.nixos.pc.james = {...}: {
        imports = with self.modules.nixos; [
            # TODO: Should be importing a version of my user module
            hyprland
            docker
            steam
            gamemode
            gamescope
            wivrn
            # alvr
            micro-controller
            # pia-openvpn
            # language-tool
            gnome-keyring
        ];
        config = {
            my = {
                services.docker.groupUsers = ["james"];
                gamemode.users = ["james"];
                services.micro-controller.udevGroupMembers = ["james"];
                tools.wireshark.users = ["james"];
            };
        };
    };
    # flake.modules.home.pc.james = {...}: {};
}
