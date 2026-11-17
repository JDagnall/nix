# This config specifically is just for reverse proxying servers defined as servers
# If I want to do anything else with caddy I would split this up into a general
# caddy module, that just creates the servers, one for the reverse proxying and
# another for whatever the new thing is.
{
    self,
    lib,
    inputs,
    ...
}: {
    flake.modules.nixos.caddy = {
        pkgs,
        config,
        ...
    }: let
        cfg = config.my.servers.proxy.caddy;
        # default route http server location
        # relative to /etc
    in {
        key = "my/nixos/caddy";
        imports = with self.modules.nixos; [servers reverseProxy sops];
        options.my = {
            servers.proxy.caddy = {
                email = lib.mkOption {
                    description = "Email to use for the acme certificates.";
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                };
                rootCACert = lib.mkOption {
                    description = ''
                        The root certificate for caddy's internal TLS. The key must be
                        provided in sops.
                    '';
                    type = lib.types.str;
                };
                hostNameTLSConfig = lib.mkOption {
                    type = with lib.types; attrsOf str;
                    description = ''
                        String to put into a `tls` block for the hostname.
                        Key must exactly match the hostname.
                    '';
                    default = {};
                };
                extraHandlers = lib.mkOption {
                    description = ''
                        Functions that take a hostname and return a caddy handler
                        in the form of a string. Will be added to all virtualhosts
                        in `config.my.servers.publicHostNames`. If the handler is
                        only for specific hostnames, add a check and return "" if
                        the hostname does not match.
                    '';
                    type = with lib.types; listOf (functionTo str);
                    default = [];
                };
            };
        };
        config = {
            my.servers.reverseProxy.type = "caddy";
            users.users."caddy".extraGroups = [config.my.servers.reverseProxy.group];

            sops.secrets = let
                host = config.networking.hostName;
                secretCfg = {
                    sopsFile = "${inputs.secrets}/${host}/caddy.yaml";
                    owner = "caddy";
                    mode = "0400";
                };
            in {
                "caddy/rootCAKey" = secretCfg;
            };
            # trust caddy's root CA
            security.pki.certificates = [
                cfg.rootCACert
            ];
            # caddy wants it for certificate stuff
            environment.systemPackages = with pkgs; [nss];
            services.caddy = {
                enable = true;
                openFirewall = true;
                email = cfg.email;
                # acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
                # dataDir = ;
                enableReload = false;
                # environmentFile = ; # sops
                extraConfig = "";

                # specify caddy's root CA
                globalConfig = ''
                    pki {
                        ca local {
                            name "Orion Caddy Root CA"
                            root {
                                cert ${pkgs.writeText "caddy-root-CA-cert.crt" cfg.rootCACert}
                                key ${config.sops.secrets."caddy/rootCAKey".path}
                            }
                        }
                    }
                '';
                user = "caddy";
                group = "caddy";
                # httpPort = ;
                # httpsPort = ;
                # logDir = ;
                # settings = {};
                virtualHosts = let
                    activeSubdomainServers = lib.filter (x: x.reverseProxy.enable && x.dns.enable) (lib.attrValues config.my.servers.servers);
                    mkServerSSL = server: ''
                        transport http {
                            tls
                            tls_trusted_ca_certs ${server.reverseProxy.SSLCert}
                        }
                    '';
                    mkServerSubdomain = server: hostname: ''
                        @${server.name} host ${server.name}.${hostname}
                        handle @${server.name} {
                            reverse_proxy ${
                            if server.reverseProxy.useSSL
                            then "https://"
                            else "http://"
                        }localhost:${toString server.port} {
                                ${lib.optionalString server.reverseProxy.useSSL (mkServerSSL server)}
                                ${server.reverseProxy.extraCaddyProxyCfg or ""}
                            }
                            ${server.reverseProxy.extraSubDomainCfg or ""}
                        }
                    '';
                    mkTLSBlock = TLSCfg: ''
                        tls {
                            ${TLSCfg}
                        }
                    '';
                    mkHostname = hostname: {
                        extraConfig = ''
                            ${lib.optionalString (cfg.hostNameTLSConfig ? ${hostname}) (mkTLSBlock cfg.hostNameTLSConfig.${hostname})}
                            ${lib.concatStringsSep "\n" (map (server: mkServerSubdomain server hostname) activeSubdomainServers)}
                            ${lib.concatMapStringsSep "\n" (handler: handler hostname) cfg.extraHandlers}
                            handle {
                                abort
                            }
                        '';
                        serverAliases = [hostname]; # the actual hostname without the wildcard. Is important for TLS
                    };
                in
                    lib.genAttrs' config.my.servers.publicHostNames
                    (hostname: lib.nameValuePair "*.${hostname}" (mkHostname hostname));
            };
        };
    };
}
