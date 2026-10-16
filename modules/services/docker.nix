{lib, ...}: {
    flake.modules.nixos.docker = {
        pkgs,
        config,
        ...
    }: {
        options.my = {
            services.docker.groupUsers = lib.mkOption {
                default = [];
                type = with lib.types; listOf str;
                description = "Names of users to be added to the docker group.";
            };
        };
        config = {
            virtualisation.docker = {
                enable = true;
                # dont think i want rootless, but you can do it like this
                # rootless = {
                #     enable = true;
                #     setSocketVariable = null;
                # };
                # cmd line options for daemon
                extraOptions = "";
                # https://docs.docker.com/reference/cli/dockerd/#daemon-configuration-file
                # daemon.settings = { };
                # peridoically run docker prune to keep resource use low. should maybe turn on
                autoPrune = {
                    enable = false;
                    dates = "weekly"; # could be daily
                    persistent = true;
                    flags = ["--all"];
                };
            };
            # assumes docker-compose is wanted
            environment.systemPackages = with pkgs; [docker-compose];
            users.extraGroups.docker.members = config.service.docker.groupUsers;
        };
    };
}
