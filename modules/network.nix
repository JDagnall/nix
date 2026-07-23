{
    lib,
    config,
    ...
}: let
    cfg = config.network;
in {
    options = {
        network = {
            enable = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Enable very basic and top level network config, should probably be always on for all hosts.";
            };
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
    config = lib.mkIf cfg.enable {
        networking = {
            # hosts = [];
            # cloudflare
            nameservers = ["1.1.1.1" "1.0.0.1" "2606:4700:4700::1111"];
        };
    };
}
