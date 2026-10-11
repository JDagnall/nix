# This config specifically is just for reverse proxying services defined as servers
# If I want to do anything else with caddy I would split this up into a general
# caddy module, that just creates the service, one for the reverse proxying and
# another for whatever the new thing is.
# TODO: maybe need a config interface for 'proxy' to prevent conflicting proxies?
{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.caddy = {config, ...}: let
        cfg = config.my.servers.proxy.caddy;
        # default route http server location
        # relative to /etc
        host = config.networking.hostName;
        tailscaleEnabled = config.my.services.tailscale.enabled;
    in {
        imports = with self.modules.nixos; [servers tailscale-interface];
        options.my = {
            servers.proxy.caddy = {
                email = lib.mkOption {
                    description = "Email to use for the acme certificates.";
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                };
                hostnames = lib.mkOption {
                    description = "Host names to create virtual hosts for each server.";
                    type = with lib.types; listOf str;
                    default = ["${host}.home"] ++ lib.optional tailscaleEnabled ["${host}.tail"];
                };
            };
        };
        config = let
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
        in {
            environment.etc = lib.mergeAttrsList caddy_homepage_links;
            services.caddy = {
                enable = true;
                openFirewall = true;
                # acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
                # dataDir = ;
                enableReload = false;
                # environmentFile = ; # sops
                extraConfig = "";
                globalConfig = "";
                user = "caddy";
                group = "caddy";
                # httpPort = ;
                # httpsPort = ;
                # logDir = ;
                # settings = {};
                virtualHosts = let
                    activeServices = lib.filter (x: x.mkRevProxy) (lib.attrValues config.my.servers.servers);
                    mkServiceSubDomain = service: {
                        "${service.name}.${host}.local" = {
                            extraConfig = ''
                                tls internal
                                reverse_proxy localhost:${toString service.port} {
                                    ${service.extraRevProxyCfg or ""}
                                }
                                ${service.extraSubDomainCfg or ""}
                            '';
                            serverAliases = map (hostname: "${service.name}.${hostname}") cfg.hostnames;
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
                            serverAliases = cfg.hostnames;
                        };
                    }
                    // lib.mergeAttrsList (map (x: mkServiceSubDomain x) activeServices);
            };
        };
    };
}
