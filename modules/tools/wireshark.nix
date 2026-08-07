{
    lib,
    config,
    ...
}: let
    cfg = config.tools.wireshark;
in {
    options = {
        tools.wireshark = {
            enable = lib.mkEnableOption "Enable wireshark.";
            users = lib.mkOption {
                default = [];
                type = with lib.types; listOf str;
                description = "Users to add the wireshark group.";
            };
        };
    };
    config = lib.mkIf cfg.enable {
        programs.wireshark = {
            enable = true;
            # package = pkgs.wireshark; # includes tshark
            # just assuming that if you want wireshark you want it to
            # be able to read traffic
            dumpcap.enable = true; # permission pcap network traffic
            usbmon.enable = false; # permission to pcap usb traffic
        };
        users.groups."wireshark".members = cfg.users;
    };
}
