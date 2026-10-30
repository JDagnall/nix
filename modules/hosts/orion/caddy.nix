# TODO: may be possible to move the 'domain' bit of this into
# the main caddy config
{
    self,
    lib,
    inputs,
    ...
}: {
    flake.modules.nixos.orion = {
        pkgs,
        config,
        ...
    }: {
        imports = with self.modules.nixos; [caddy sops];
        config = {
            sops = {
                secrets = {
                    "caddy/cloudflare_api_token" = {sopsFile = "${inputs.secrets}/orion/caddy.yaml";};
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
            my.servers.proxy.caddy.email = "james.t.dagnall@gmail.com";
            services.caddy = let
                domain = "home.waluigimangione.dev";
            in {
                package = pkgs.caddy.withPlugins {
                    plugins = ["github.com/caddy-dns/cloudflare@v0.2.4"];
                    hash = "sha256-5a5cpFl90pEWt0lUC4ZJQ7g+1//ZvsRhee64Dt9vh5o=";
                };
                virtualHosts = let
                    activeServices = lib.filter (x: x.mkRevProxy) (lib.attrValues config.my.servers.servers);
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
    };
}
