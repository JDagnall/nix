{
    self,
    lib,
    inputs,
    ...
}: {
    flake.modules.nixos.keycloak = {config, ...}: {
        imports = with self.modules.nixos; [servers sops reverseProxy];
        config = let
            # cfg= config.my.servers.keycloak;
            serverCfg = config.my.servers.servers.keycloak;
            # keycloak recommends stripping these headers for security measures as
            # it is a security platform.
            stripped_headers = [
                "Forwarded"
                # caddy overwrites these by default
                # "X-Forwarded-For"
                # "X-Forwarded-Proto"
                # "X-Forwarded-Host"
                "X-Forwarded-Port"
                "X-Forwarded-Prefix"
                "X-Original-Forwarded-For"
                "X-Real-IP"
                "X-Original-URL"
                "X-Original-Method"
                "X-Forwarded-Access-Token"
                "traceparent"
                "tracestate"
                "baggage"
                "b3"
                "x-b3-traceid"
                "x-b3-spanid"
                "x-b3-parentspanid"
                "x-b3-sampled"
                "x-b3-flags"
                "uber-trace-id"
                "x-ot-span-context"
            ];
        in {
            my.servers.servers.keycloak = {
                port = 5658;
                user = "keycloak";
                group = "keycloak";
                reverseProxy = {
                    enable = true;
                    useSSL = true;
                    SSLCert = config.sops.secrets."keycloak/SSLCert".path;
                    extraCaddyProxyCfg = ''
                        ${lib.concatStringsSep "\n" (map (h: "header_up -${h}") stripped_headers)}
                    '';
                };
                dns.enable = true;
                dashboardIcon = {
                    enable = true;
                    icon = builtins.fetchurl {
                        url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/keycloak.svg";
                        sha256 = "03h69sjwbq8hgvwp7qgf173klpj075szyiq0mygzlz5q3d4hiya9";
                        name = "keycloak.svg";
                    };
                };
            };
            sops.secrets = let
                host = config.networking.hostName;
                secretCfg = {sopsFile = "${inputs.secrets}/${host}/keycloak.yaml";};
            in {
                "keycloak/dbPass" = secretCfg;
                "keycloak/SSLCert" =
                    secretCfg
                    // {
                        mode = "0440";
                        # needs to be accessible by the reverse proxy
                        group = config.my.servers.reverseProxy.group;
                    };
                "keycloak/SSLKey" = secretCfg;
            };
            services.keycloak = {
                enable = true;
                # package = ;
                # themes = {} ;
                # plugins = {};
                settings = {
                    # TODO: this sucks obviously you should be able to specify
                    # multiple hostnames so this is a very bandaid soloution
                    hostname = "keycloak.${lib.head config.my.servers.publicHostNames}";
                    http-host = serverCfg.host; # only listen on localhost
                    http-port = 12057; # random high port, not using http
                    # https-host = serverCfg.host;
                    https-port = serverCfg.port;
                    # http-relative-path = "/";
                    hostname-backchannel-dynamic = false;

                    # PROXY SETTINGS
                    # caddy default, would need to add directives in ExtraRevPrxyCfg
                    # in nginx or whatever
                    proxy-headers = "xforwarded";
                    proxy-trusted-addresses = "127.0.0.1";
                };
                # realmFiles = [ ] ;
                database = {
                    # defaults
                    host = "localhost";
                    name = "keycloak";
                    # port = ;
                    username = "keycloak";
                    type = "postgresql";
                    createLocally = true;
                    passwordFile = config.sops.secrets."keycloak/dbPass".path;
                    caCert = null; # because localhost
                    useSSL = false; # because localhost
                };
                sslCertificate = config.sops.secrets."keycloak/SSLCert".path;
                sslCertificateKey = config.sops.secrets."keycloak/SSLKey".path;
                initialAdminPassword = "pass";
            };
        };
    };
}
