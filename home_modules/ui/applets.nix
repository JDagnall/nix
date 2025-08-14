{ lib, config, ... }:
let
    inherit (lib) mkEnableOption mkIf;
    inherit (config.ui) bt-applet nm-applet;
    inherit (config) blueman network-manager;
in
{
    options = {
        ui.bt-applet.enable = mkEnableOption {
            description = "Enable the blueman applet";
        };
        ui.nm-applet.enable = mkEnableOption {
            description = "Enable network manager applet";
        };
    };
    config = {
        assertions = [
            {
                assertion = blueman.enabled || !bt-applet.enable;
                message = ''
                    Blueman is required for the blueman applet. It is configured in nixos,
                    but is set to disabled semantically in the home-manager system_services module.
                    Make sure blueman is configured and this options is set to true.
                '';
            }
            {
                assertion = network-manager.enabled || !nm-applet.enable;
                message = ''
                    Network manager is required for the network manager applet. It is configured in nixos,
                    but is set to disabled semantically in the home-manager system_services module.
                    Make sure network manager is configured and this options is set to true.
                '';
            }
        ];
        services.blueman-applet = mkIf bt-applet.enable {
            enable = true;
        };
        services.network-manager-applet = mkIf nm-applet.enable {
            enable = true;
        };
        # this creates the target for the system tray if needed. Should maybe be moved elsewhere
        # the applets services wont start without them
        systemd.user.targets.tray = mkIf (nm-applet.enable || bt-applet.enable) {
            Unit = {
                Description = "Home Manager System Tray";
                Requires = [ "graphical-session-pre.target" ];
            };
        };

    };
}
