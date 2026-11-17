{
    self,
    lib,
    # inputs,
    ...
}: {
    flake.modules.nixos.nextcloud-interface = {
        key = "my/nixos/nextcloud-interface"; # intended to be imported many times
        options = {
            my.servers.nextcloud.enabled = lib.mkEnableOption "Nextcloud is enabled";
        };
    };
    flake.modules.nixos.nextcloud = {
        pkgs,
        config,
        ...
    }: {
        imports = with self.modules.nixos; [
            servers
            nextcloud-interface
            collabora-interface
        ];
        options = {
            my.servers.nextcloud = {
                dataDir = lib.mkOption {
                    default = "/var/lib/nextcloud";
                    type = with lib.types; path;
                    description = "The directory that nextcloud should operate in, must be specified.";
                };
                enableRichDocuments = lib.mkEnableOption "Enable rich documents support, if a collabora instance is configured it will use that. For the moment, " // {default = true;};
            };
        };
        config = let
            cfg = config.my.servers.nextcloud;
            serverCfg = config.my.servers.servers.nextcloud;
        in {
            my.servers.servers.nextcloud = rec {
                port = 9267;
                user = "nextcloud";
                group = "nextcloud";
                reverseProxy = {
                    enable = true;
                    extraCaddyProxyCfg = ''
                        header_up Host ${nginxVHost}
                    '';
                };
                nginxVHost = "nextcloud.localhost";
                dns.enable = true;
                dashboardIcon = {
                    enable = true;
                    icon = builtins.fetchurl {
                        url = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/svg/nextcloud.svg";
                        sha256 = "0h3jja2wqvb67whc6k6mbykd9p2q26bgiwmn01lrdpags37lk4zi";
                        name = "nextcloud.svg";
                    };
                };
            };
            my.servers.nextcloud.enabled = true;
            services.nextcloud = {
                enable = true;
                home = cfg.dataDir;
                # the nextcloud module does a realy weird thing and sets up all the
                # config files as systemd tmpfiles which does not play nice if the
                # nextcloud home directory is on a zfs mount like mine is.
                # This directory is only for some config files so it's probs fine
                datadir = cfg.dataDir;
                package = pkgs.nextcloud35;
                https = false; # rev proxy
                secretFile = null;
                # phpOptions = {};
                hostName = serverCfg.nginxVHost;
                settings = {
                    maintenance_window_start = 1;
                    default_phone_region = "AU"; # TODO: need some kind of parent localisation settings
                    log_type = "systemd";
                    serverid = 0;
                    # because this will be behind a reverse proxy
                    overwriteprotocol = "https";
                    trusted_proxies = ["127.0.0.1"];
                    trusted_domains = map (hostname: "nextcloud.${hostname}") config.my.servers.publicHostNames;
                };
                config = {
                    dbtype = "sqlite";
                    dbuser = "nextcloud";
                    # dbpassFile = config.sops.secrets."nextcloud/dbPass".path;
                };
                appstoreEnable = false; # idk if I need this
                extraAppsEnable = true;
                extraApps = {
                    # TODO: there are other types of rich document support.
                    # If more are implemented as modules there needs to be an enum option for this
                    richdocuments = lib.mkIf cfg.enableRichDocuments pkgs.nextcloud35Packages.apps.richdocuments;
                    # This is a local and slower
                    richdocumentscode = lib.mkIf (cfg.enableRichDocuments && !config.my.servers.collabora.enabled) (pkgs.fetchNextcloudApp {
                        appName = "richdocumentscode";
                        appVersion = "26.4.502";
                        license = "asl20";
                        sha256 = "0478j9hk06blfbvx2p85jzxp43m7rq3ydysj4m5bvp8kadm4bxsy";
                        url = "https://github.com/CollaboraOnline/richdocumentscode/archive/refs/tags/26.4.502.tar.gz";
                    });
                    # could do this, it needs the `services.nextcloud-whiteboard-server` to be enabled
                    # whiteboard = pkgs.nextcloud35Packages.apps.whiteboard;
                };
                database = {
                    createLocally = true;
                };
            };
            # nextcloud uses nginx kind of like a web server, obviously it would
            # be better if it used caddy, but for now caddy will just redirect to
            # nginx which will redirect to nextcloud
            services.nginx.virtualHosts."${serverCfg.nginxVHost}" = {
                listen = lib.mkForce [
                    {
                        addr = serverCfg.host;
                        port = serverCfg.port;
                    }
                ];
                forceSSL = lib.mkForce false;
                enableACME = lib.mkForce false;
            };
        };
    };
}
