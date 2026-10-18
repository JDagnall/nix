# Servers in this repo are supposed to be services that are intended to be
# `forwarded`, meaning externally accessible whether just on the local network
# or otherwise. And thus each `server` defines its port and access and how it
# wants be forwared (rev proxy, subdomain, etc)
{lib, ...}: {
    flake.modules.nixos.servers = {...}: {
        key = "my/nixos/servers";
        options.my = {
            servers = {
                servers = lib.mkOption {
                    type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
                        freeformType = lib.types.attrsOf lib.types.anything;
                        options = {
                            name = lib.mkOption {
                                type = lib.types.str;
                                default = name;
                            };
                            host = lib.mkOption {
                                type = lib.types.str;
                                default = "localhost";
                                description = "Listen address.";
                            };
                            # should maybe be a list?
                            port = lib.mkOption {
                                type = lib.types.port;
                                description = "Port that the server runs on";
                            };
                            user = lib.mkOption {
                                type = lib.types.nullOr lib.types.str;
                                description = "The user that this server runs under.";
                            };
                            group = lib.mkOption {
                                type = lib.types.nullOr lib.types.str;
                                description = "The group that this server runs under.";
                            };
                            mkRevProxy = lib.mkOption {
                                type = lib.types.bool;
                                description = "Whether to reverse proxy this service.";
                                default = false;
                            };
                            openFirewall = lib.mkOption {
                                type = lib.types.bool;
                                description = "Whether to open this servers port.";
                                default = false;
                            };
                            # there should be an access option here that defines along with some
                            # identity provider and an `accounts` module, who can access a service
                        };
                    }));
                };
            };
        };
    };
}
