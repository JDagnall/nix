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
            activeServices = lib.mkOption {
                description = "Currently active media services.";
                default = [];
                type = with lib.types;
                    listOf (submodule {
                        options = {
                            name = lib.mkOption {
                                type = str;
                                description = "Name of the service";
                            };
                            port = lib.mkOption {
                                type = port;
                                description = "Port that the service runs on";
                            };
                        };
                    });
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
                ++ lib.optionals (config.users.users ? sonarr) ["sonarr"]
                ++ lib.optionals (config.users.users ? radarr) ["radarr"]
                ++ lib.optionals (config.users.users ? jackett) ["jackett"]
                ++ lib.optionals (config.users.users ? transmission) ["transmission"];
        };
        # defining the active services here for now instead on in each services file
        # respectively. This will all be redone in the move to denritic anyway.
        service.media-services.activeServices =
            []
            ++ lib.optional config.service.syncthing.enable {
                name = "syncthing";
                port = 8384;
            }
            ++ lib.optional cfg.qbittorrent.enable {
                name = "qbittorrent";
                port = 9494;
            }
            ++ lib.optional cfg.transmission.enable {
                name = "transmission";
                port = 9091;
            }
            ++ lib.optional cfg.jellyfin.enable {
                name = "jellyfin";
                port = 8096;
            }
            ++ lib.optional cfg.sonarr.enable {
                name = "sonarr";
                port = 8989;
            }
            ++ lib.optional cfg.radarr.enable {
                name = "radarr";
                port = 7878;
            }
            ++ lib.optional cfg.prowlarr.enable {
                name = "prowlarr";
                port = 9696;
            }
            ++ lib.optional cfg.flaresolverr.enable
            {
                name = "flaresolverr";
                port = 8191;
            }
            ++ lib.optional cfg.jackett.enable {
                name = "jackett";
                port = 9117;
            }
            ++ lib.optional cfg.seerr.enable {
                name = "seerr";
                port = 5055;
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
    ];
}
