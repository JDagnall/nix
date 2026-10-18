{lib, ...}: {
    flake.modules.nixos.gamemode = {
        pkgs,
        config,
        ...
    }: {
        options = {
            my.gaming.gamemode = {
                users = lib.mkOption {
                    default = [];
                    type = lib.types.listOf lib.types.str;
                    description = "List of users to add to the gamemode group.";
                };
            };
        };
        config = {
            users.groups."gamemode".members = config.my.gaming.gamemode.users;
            programs.gamemode = {
                enable = true;
                enableRenice = true;
                settings = {
                    custom = {
                        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
                        end = "${pkgs.libnotify}/bin/notify-send 'GameMode exited'";
                    };
                };
            };
        };
    };
}
