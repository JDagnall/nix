# This is just a patch since the config here obviously does not belong with the general
# config in modules. Dendritic suits this far better.
{
    pkgs,
    lib,
    config,
    ...
}: {
    options = {
        service.caddy = {
            orion = {
                enable = lib.mkEnableOption "Enable the specific domain configuration for orion, with cloudflare DNS challeges.";
                domainName = lib.mkOption {
                    type = lib.types.str;
                    description = "The domain name to configure cloudflare for.";
                };
            };
        };
    };
    config = lib.mkIf config.service.caddy.orion.enable {
        assertions = [
            {
                assertion = config.sops.enable;
                message = "Sops needs to be enabled to provided the cloudflare token to caddy.";
            }
            {
                assertion = config.service.caddy.enable;
                message = "Caddy needs to be enabled to enable the orion specific caddy config.";
            }
        ];
        sops = {
            secrets = let
                host = config.networking.hostName;
            in {
                "caddy/cloudflare_api_token" = {sopsFile = ../../secrets/${host}/caddy.yaml;};
            };
            templates = let
                sops-placeholder = config.sops.placeholder;
            in {
                "caddy-env-file" = {
                    content = ''
                        CLOUDFLARE_API_TOKEN=${sops-placeholder."caddy/cloudflare_api_token"}
                    '';
                };
            };
        };
        systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.templates."caddy-env-file".path;
        services.caddy = {
            package = pkgs.caddy.withPlugins {
                plugins = ["github.com/caddy-dns/cloudflare@v0.2.4"];
                hash = "sha256-7GoH8YLCoPmPExQxoga2FHB58zQDoZVf1BBwkVi0SsQ=";
            };
            virtualHosts = let
                domain = config.service.caddy.orion.domainName;
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
                mkServiceSubdomain = service: ''
                    @${service.name} host ${service.name}.${domain}
                    handle @${service.name} {
                        reverse_proxy localhost:${toString service.port} {
                            ${service.extraRevProxyCfg or ""}
                        }
                        ${service.extraSubDomainCfg or ""}
                    }

                '';
            in {
                "*.${domain}" = {
                    extraConfig = ''
                        tls {
                            dns cloudflare {env.CLOUDFLARE_API_TOKEN}
                        }
                        @dashboard host ${domain}
                        handle @dashboard {
                                root /etc/caddy/www
                                vars activeServices "${lib.concatStringsSep " " (map (x: x.name) activeServices)}"
                                templates {
                                    mime text/html text/plain text/javascript
                                }
                                file_server
                        }
                        ${lib.concatStringsSep "\n" (map mkServiceSubdomain activeServices)}
                        handle {
                            abort
                        }
                    '';
                    serverAliases = [domain]; # for the regular domain
                };
            };
        };
    };
}
