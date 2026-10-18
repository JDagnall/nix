{lib, ...}: {
    flake.modules.nixos.network = {config, ...}: let
        # cfg = config.network;
    in {
        key = "my/nixos/network";
        options.my = {
            network = {
                physicalInterfaces = lib.mkOption {
                    type = with lib.types; listOf str;
                    default = [];
                    description = "Names of physical network interfaces.";
                };
                loopbackInterface = lib.mkOption {
                    type = lib.types.str;
                    default = "lo";
                    description = "Name of the loopback interface, probably always going to be the default.";
                };
            };
        };
        config = {
            networking = {
                # hosts = [];
                # cloudflare
                nameservers = ["1.1.1.1" "1.0.0.1" "2606:4700:4700::1111"];
            };
        };
    };
}
