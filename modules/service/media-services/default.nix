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
            services = lib.mkOption {
                type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
                    freeformType = lib.types.attrsOf lib.types.anything;
                    options = {
                        name = lib.mkOption {
                            type = lib.types.str;
                            default = name;
                        };
                        port = lib.mkOption {
                            type = lib.types.port;
                            description = "Port that the service runs on";
                        };
                        user = lib.mkOption {
                            type = lib.types.nullOr lib.types.str;
                            description = "The user that this service runs under.";
                        };
                        inMediaGroup = lib.mkOption {
                            type = lib.types.bool;
                            default = false;
                            description = "Whether the user the service runs under should be added to the media group.";
                        };
                        mkRevProxy = lib.mkOption {
                            type = lib.types.bool;
                            description = "Whether to reverse proxy this service.";
                            default = false;
                        };
                    };
                }));
            };
        };
    };
    config = lib.mkIf cfg.enable {
        users.groups.${cfg.group.name} = {
            # gid = 999;
            members =
                lib.uniqueStrings (lib.map (x: x.user) (lib.filter (x: x.inMediaGroup) (lib.attrValues cfg.services)));
        };
    };

    imports = [
        ./jellyfin.nix
        ./qbittorrent.nix
        ./sonarr.nix
        ./prowlarr.nix
        ./radarr.nix
        ./seerr.nix
        ./transmission.nix
        ./flaresolverr.nix
        ./jackett.nix
        ./immich.nix
        ./syncthing.nix
    ];
}
