# This config specifically is just for allowing access to advertised services through subdomains
# anything else to do with reverse proxying, will be put in a separate file
{
    lib,
    config,
    ...
}: {
    options = {
        service.caddy = {
            enable = lib.mkEnableOption "Enable caddy, a reverse proxy.";
            email = lib.mkOption {
                description = "Email to use for the acme certificates.";
                type = lib.types.nullOr lib.types.str;
                default = null;
            };
        };
    };
    config = let
        # cfg = config.service.caddy;
        # default route http server location
        # relative to /etc
        default_http_path = "caddy/www";
        # grabs all the non-nix files from this directory
        caddy_homepage_files = lib.fileset.toList (lib.fileset.fileFilter (file: !file.hasExt "nix") ./.);
        caddy_homepage_links = map (x: {
            "${default_http_path}/${baseNameOf x}" = {
                source = x;
                user = config.services.caddy.user;
                group = config.services.caddy.group;
            };
        })
        caddy_homepage_files;
    in
        lib.mkIf config.service.caddy.enable {
            environment.etc = lib.mergeAttrsList caddy_homepage_links;
            services.caddy = {
                enable = true;
                openFirewall = true;
                # acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
                # dataDir = ;
                enableReload = false;
                # environmentFile = ; # sops
                email = config.service.caddy.email;
                extraConfig = "";
                globalConfig = "";
                # user = "caddy";
                # group = "caddy";
                # httpPort = ;
                # httpsPort = ;
                # logDir = ;
                # settings = {};
                virtualHosts = let
                    host = config.networking.hostName;
                    tailnet = config.service.tailscale.tailnet;
                    tailscaleEnabled = config.service.tailscale.enable && tailnet != null;
                    domainAliases = ["home" "tail"] ++ lib.optionals tailscaleEnabled ["${tailnet}.ts.net"];
                    servicesCfg = config.service;
                    activeServices =
                        []
                        ++ lib.optionals servicesCfg.syncthing.enable [
                            {
                                name = "syncthing";
                                port = 8384;
                            }
                        ]
                        ++ lib.optionals servicesCfg.media-services.qbittorrent.enable [
                            {
                                name = "qbittorrent";
                                port = 9494;
                            }
                        ]
                        ++ lib.optionals servicesCfg.media-services.jellyfin.enable [
                            {
                                name = "jellyfin";
                                port = 8096;
                            }
                        ]
                        ++ lib.optionals servicesCfg.media-services.sonarr.enable [
                            {
                                name = "sonarr";
                                port = 8989;
                            }
                        ]
                        ++ lib.optionals servicesCfg.media-services.radarr.enable [
                            {
                                name = "radarr";
                                port = 7878;
                            }
                        ]
                        ++ lib.optionals servicesCfg.media-services.prowlarr.enable [
                            {
                                name = "prowlarr";
                                port = 9696;
                            }
                        ]
                        ++ lib.optionals servicesCfg.media-services.flaresolverr.enable [
                            {
                                name = "flaresolverr";
                                port = 8191;
                            }
                        ]
                        ++ lib.optionals servicesCfg.media-services.seerr.enable [
                            {
                                name = "seerr";
                                port = 5055;
                            }
                        ];
                    mkServiceSubDomain = name: port: {
                        "${name}.${host}.local" = {
                            extraConfig = ''
                                tls internal
                                reverse_proxy localhost:${toString port}
                            '';
                            serverAliases = map (x: "${name}.${host}.${x}") domainAliases;
                        };
                    };
                    mkServicePath = name: port: ''
                        handle_path /${name}* {
                        	reverse_proxy localhost:${toString port}
                        }
                    '';
                in
                    {
                        "${host}.local" = {
                            extraConfig = ''
                                tls internal
                                root /etc/${default_http_path}
                                vars activeServices "${lib.concatStringsSep " " (map (x: x.name) activeServices)}"
                                templates {
                                    mime text/html text/plain text/javascript
                                }
                                file_server
                                ${lib.concatStringsSep "\n" (map (x: mkServicePath x.name x.port) activeServices)}
                            '';
                            serverAliases = map (x: "${host}.${x}") domainAliases;
                        };
                    }
                    // lib.mergeAttrsList (map (x: mkServiceSubDomain x.name x.port) activeServices);
            };
        };
}
