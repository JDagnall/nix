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
                    alternativeTLDs = ["home" "tail"] ++ lib.optionals tailscaleEnabled ["${tailnet}.ts.net"];
                    activeServices = map (service:
                        service
                        // lib.mkIf (service.name == "qbittorrent") {
                            # qbittorrent really does not like reverse proxies
                            extraRevProxyCfg = ''
                                header_up Host localhost:9494
                                header_up X-Forwarded-Host {hostport}
                                header_up -Origin
                                header_up -Referer
                            '';
                        })
                    config.service.media-services.activeServices;
                    mkServiceSubDomain = service: hostname: TLDs: {
                        "${service.name}.${hostname}.local" = {
                            extraConfig = ''
                                tls internal
                                reverse_proxy localhost:${toString service.port} {
                                    ${service.extraRevProxyCfg or ""}
                                }
                                ${service.extraSubDomainCfg or ""}
                            '';
                            serverAliases = map (x: "${service.name}.${hostname}.${x}") TLDs;
                        };
                    };
                    mkServicePath = service: ''
                        handle_path /${service.name}* {
                        	reverse_proxy localhost:${toString service.port} {
                                    ${service.extraRevProxyCfg or ""}
                            }
                            ${service.extraSubPathCfg or ""}
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
                                ${lib.concatStringsSep "\n" (map (x: mkServicePath x) activeServices)}
                            '';
                            serverAliases = map (x: "${host}.${x}") alternativeTLDs;
                        };
                    }
                    // lib.mergeAttrsList (map (x: mkServiceSubDomain x host alternativeTLDs) activeServices);
            };
        };
}
