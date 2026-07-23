{
    pkgs,
    lib,
    config,
    ...
}: let
    cfg = config.service.vpn.pia.openvpn;
in {
    options = {
        service.vpn.pia.openvpn = {
            enable = lib.mkEnableOption ''
                Enable PIA openvpn config, this config is only a regular nixos openvpn service
                + a network manager config.
            '';
            defaultInterfaceName = lib.mkOption {
                default = "tun";
                type = lib.types.str;
                description = "Name of the interface the vpn will create and bind to. Not specifying a number will assign a dynamic one.";
            };
        };
    };
    config = let
        torrentConCfg = config.service.vpn.pia.torrentCon;
        torrentConEnabled = torrentConCfg.enable && torrentConCfg.type == "openvpn";
        torrentDev = torrentConCfg.interface;
        defaultDevice = cfg.defaultInterfaceName;
    in
        lib.mkIf (config.service.vpn.pia.enable && cfg.enable) {
            sops = lib.mkIf config.sops.enable {
                templates = {
                    "PIA-login" = {
                        content = ''
                            ${config.sops.placeholder."VPN/PIA/user"}
                            ${config.sops.placeholder."VPN/PIA/pass"}
                        '';
                    };
                    "NetworkManager-profiles-env" = {
                        content = "PIA_USERNAME=${config.sops.placeholder."VPN/PIA/user"}";
                    };
                };
            };

            services.openvpn = {
                restartAfterSleep = true;
                # these get turned into system services
                servers = let
                    mkOvpnCfg = cfg: {
                        config =
                            ''
                                config ${cfg.ovpnCfg}
                                auth-nocache
                                dev-type tun
                                dev ${cfg.dev}
                            ''
                            + cfg.extraCfg or "";
                        autoStart = cfg.autoStart;
                        updateResolvConf = true;
                        authUserPass = config.sops.templates."PIA-login".path;
                    };
                in {
                    PIA-Melbourne = mkOvpnCfg {
                        ovpnCfg = toString ./PIA_melbourne.ovpn;
                        dev = defaultDevice;
                        autoStart = false;
                    };
                    PIA-Brisbane = mkOvpnCfg {
                        ovpnCfg = toString ./PIA_brisbane.ovpn;
                        dev = defaultDevice;
                        autoStart = false;
                    };
                    # will only redirect traffic bound to the device
                    PIA-torrent = lib.mkIf torrentConEnabled (mkOvpnCfg {
                        ovpnCfg = toString ./PIA_melbourne.ovpn;
                        dev = torrentDev;
                        autoStart = true;
                        extraCfg = ''
                            pull-filter ignore redirect-gateway
                        '';
                    });
                };
            };

            networking.networkmanager = lib.mkIf config.networking.networkmanager.enable {
                plugins = [
                    pkgs.networkmanager-openvpn
                ];
                # use google and cloudflare nameservers
                # insertNameservers = ["8.8.8.8" "1.1.1.1"];
                ensureProfiles = {
                    environmentFiles = lib.mkIf config.sops.enable [
                        config.sops.templates."NetworkManager-profiles-env".path
                    ];
                    profiles = {
                        PIA_openvpn_brisbane = {
                            connection = {
                                id = "PIA_openvpn_brisbane";
                                type = "vpn";
                                autoconnect = false;
                            };
                            ipv4 = {
                                # first two are PIA DNS
                                dns = "10.0.0.242;10.0.0.243;8.8.8.8;1.1.1.1;";
                                method = "auto";
                            };
                            ipv6 = {
                                method = "disabled";
                            };
                            proxy = {};
                            vpn = {
                                ca = "${./servers/cert.pem}";
                                # password-flags = "0"; # secrets stored in network manager root readable file
                                password-flags = "1"; # secrets stored in nm-file-secret-agent
                                username = "$PIA_USERNAME";
                                challenge-response-flags = "x-dynamic-challenge-echo:challenge-response";
                                # auth-user-pass = 1;
                                auth = "sha256";
                                proto-tcp = "no";
                                cipher = "aes-256-cbc";
                                # compress = "yes";
                                comp-lzo = "no";
                                dev = "tun";
                                remote = "au-brisbane-pf.privacy.network:1197";
                                port = 1197;
                                remote-cert-tls = "server";
                                # tls-client = 1;
                                reneg-seconds = "0";
                                # verb = 4;
                                service-type = "org.freedesktop.NetworkManager.openvpn";
                                connection-type = "password";
                            };
                        };
                        PIA_openvpn_melbourne = {
                            connection = {
                                id = "PIA_openvpn_melbourne";
                                type = "vpn";
                                autoconnect = false;
                            };
                            ipv4 = {
                                # first two are PIA DNS
                                dns = "10.0.0.242;10.0.0.243;8.8.8.8;1.1.1.1;";
                                method = "auto";
                            };
                            ipv6 = {
                                method = "disabled";
                            };
                            proxy = {};
                            vpn = {
                                ca = "${./servers/cert.pem}";
                                # password-flags = "0"; # secrets stored in network manager root readable file
                                password-flags = "1"; # secrets stored in nm-file-secret-agent
                                username = "$PIA_USERNAME";
                                challenge-response-flags = "x-dynamic-challenge-echo:challenge-response";
                                # challenge-response-flags = "1";
                                auth = "sha256";
                                proto-tcp = "no";
                                cipher = "aes-256-cbc";
                                # compress = "yes";
                                comp-lzo = "no";
                                dev = "tun";
                                remote = "aus-melbourne.privacy.network:1197";
                                port = 1197;
                                remote-cert-tls = "server";
                                # tls-client = 1;
                                reneg-seconds = "0";
                                # verb = 4;
                                service-type = "org.freedesktop.NetworkManager.openvpn";
                                connection-type = "password";
                            };
                        };
                    };
                    # for openvpn at the moment network manager defaults to using the gnome keyring to store passwords.
                    # secrets.entries =
                    # 	[]
                    # 	++ lib.optionals config.service.openvpn.PIA [
                    # 		{
                    # 			file = config.sops.secrets."VPN/PIA/pass".path;
                    # 			key = "password";
                    # 			matchId = "PIA_openvpn_melbourne";
                    # 			matchSetting = "vpn";
                    # 			matchType = "vpn";
                    # 		}
                    # 		{
                    # 			file = config.sops.secrets."VPN/PIA/pass".path;
                    # 			key = "password";
                    # 			matchId = "PIA_openvpn_brisbane";
                    # 			matchSetting = "vpn";
                    # 			matchType = "vpn";
                    # 		}
                    # 	];
                };
            };
        };
}
