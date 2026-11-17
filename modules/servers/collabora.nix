{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.collabora-interface = {...}: {
        key = "my/nixos/collabora-interface"; # intended to be imported many times
        options = {
            my.servers.collabora.enabled = lib.mkEnableOption "Collabora is enabled";
        };
    };
    flake.modules.nixos.collabora = {config, ...}: {
        imports = with self.modules.nixos; [
            collabora-interface
            nextcloud-interface
        ];
        options = {
            my.servers.collabora = {};
        };
        config = let
            serverCfg = config.my.servers.servers.collabora;
        in {
            my.servers.servers.collabora = {
                port = 9980;
                user = "collabora";
                group = "collabora";
                reverseProxy = {
                    enable = true;
                };
                dashboardIcon.enable = false;
            };
            my.servers.collabora.enabled = true;
            services.collabora-online = {
                enable = true;
                port = serverCfg.port;
                settings = {
                    ssl = {
                        enable = false; # Caddy handles TLS
                        termination = true; # but links should be generated as https
                    };
                    net = {
                        listen = "localhost";
                        post_allow.host = ["::1" "127.0.0.1"];
                    };
                    # TODO: this can be used for more than just nextcloud, but for now nextcloud
                    # is the only other module that can use it
                    # this is storage on nextcloud
                    storage.wopi = lib.mkIf config.my.servers.nextcloud.enabled {
                        # sets xml attribute in actual config file
                        "@allow" = true;
                        host = ["localhost:${toString config.my.servers.servers.nextcloud.port}"];
                    };
                };
            };
        };
    };
}
