{
    pkgs,
    lib,
    config,
    ...
}: {
    options = {
        gaming.gamemode = {
            enable = lib.mkEnableOption {
                description = "Enable gamemode. GPU optimisations for games among other things.";
            };
            users = lib.mkOption {
                default = [];
                type = lib.types.listOf lib.types.str;
                description = "List of users to add to the gamemode group.";
            };
        };
    };
    config = lib.mkIf config.gaming.gamemode.enable {
        users.groups."gamemode".members = config.gaming.gamemode.users;
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
}
