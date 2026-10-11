{...}: {
    flake.modules.nixos.james = {pkgs, ...}: {
        users.groups.james = {};
        users.users.james = {
            isNormalUser = true;
            group = "james";
            extraGroups = ["wheel"];
            initialPassword = "pass";
            packages = with pkgs; [
                vim
                git
                zsh
                bash
            ];
            shell = pkgs.zsh;
        };
        # make sure we always have a shell
        programs.zsh.enable = true;
        # keyring
        services.gnome.gnome-keyring.enable = true;
        # will attempt to unlock keyring with users password on login
        security.pam.services.james.enableGnomeKeyring = true;
    };
}
