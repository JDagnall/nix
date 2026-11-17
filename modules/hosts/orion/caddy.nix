{
    self,
    inputs,
    ...
}: {
    flake.modules.nixos.orion = {
        pkgs,
        config,
        ...
    }: {
        imports = with self.modules.nixos; [caddy caddyDashboard sops];
        config = let
            domain = "home.waluigimangione.dev";
        in {
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
            my.servers.publicHostNames = [domain];
            my.servers.proxy.caddy = {
                email = "james.t.dagnall@gmail.com";
                rootCACert = ''
                    -----BEGIN CERTIFICATE-----
                    MIIBgDCCASagAwIBAgIRALzx80E5roXVi3raPx0hQ0wwCgYIKoZIzj0EAwIwHjEc
                    MBoGA1UEAxMTT3Jpb24gQ2FkZHkgUm9vdCBDQTAeFw0yNjExMTcwMjA0MzNaFw0z
                    NjExMTQwMjA0MzNaMB4xHDAaBgNVBAMTE09yaW9uIENhZGR5IFJvb3QgQ0EwWTAT
                    BgcqhkjOPQIBBggqhkjOPQMBBwNCAARPXDmYa3oMcAmcL4vgVu6Oj44obzH2Xd/4
                    AjKgdTLRDCfeirYW+UEnGmmVcR0V982O5YjXsh8z7RPTImKXrLmso0UwQzAOBgNV
                    HQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIBATAdBgNVHQ4EFgQU6jvU7GjO
                    lMvDux1KBWR1Ltz5S+0wCgYIKoZIzj0EAwIDSAAwRQIgXo7uc06hOtqVxaI3XWNj
                    KaPwdn3DH04BC7g/PusJKhQCIQCsYyfSXA11DRmtQGnxlKxm0I5enYSZ+yAjcO+2
                    +RKryA==
                    -----END CERTIFICATE-----
                '';
                hostNameTLSConfig = {
                    ${domain} = ''
                        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
                    '';
                };
            };
            services.caddy = {
                package = pkgs.caddy.withPlugins {
                    plugins = ["github.com/caddy-dns/cloudflare@v0.2.4"];
                    hash = "sha256-5a5cpFl90pEWt0lUC4ZJQ7g+1//ZvsRhee64Dt9vh5o=";
                };
            };
        };
    };
}
