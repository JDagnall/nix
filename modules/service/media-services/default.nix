{
    lib,
    config,
    ...
}: let
    cfg = config.service.media-services;
in {
    options = {
        service.media-services = {
            enable = lib.mkEnableOption "Enable the many services that manage the media library";
            group = {
                name = lib.mkOption {
                    description = "A common group for all media-services to use, so that they can operate on the same files.";
                    default = "media";
                    type = lib.types.str;
                };
                umask = lib.mkOption {
                    description = "Umask for the group.";
                    default = 0003;
                    type = lib.types.int;
                };
            };
        };
    };
    config = lib.mkIf cfg.enable {
        users.groups.${cfg.group.name} = {
            # gid = 999;
            members =
                []
                ++ lib.optionals (config.users.users ? jellyfin) ["jellyfin"]
                ++ lib.optionals (config.users.users ? qbittorrent) ["qbittorrent"]
                ++ lib.optionals (config.users.users ? prowlarr) ["prowlarr"]
                ++ lib.optionals (config.users.users ? sonarr) ["sonarr"];
        };
    };

    imports = [
        ./jellyfin.nix
        ./qbittorrent.nix
        ./sonarr.nix
        ./prowlarr.nix
        ./radarr.nix
    ];
}
