{...}: {
    flake.modules.homeManager.nm-applet = {
        pkgs,
        osConfig,
        ...
    }: let
        inherit (osConfig.networking) networkmanager;
    in {
        config = {
            assertions = [
                {
                    assertion = networkmanager.enable;
                    message = ''
                        Network manager is required for the network manager applet. It is configured in nixos,
                        but is set to disabled semantically in the home-manager system_services module.
                        Make sure network manager is configured and this options is set to true.
                    '';
                }
            ];
            services.network-manager-applet = {
                enable = true;
            };
            # so that the commands are in the path
            home.packages = [
                pkgs.networkmanagerapplet
            ];
            # this creates the target for the system tray if needed. Should maybe be moved elsewhere
            # the applets services wont start without them
            # systemd.user.targets.tray = {
            #     Unit = {
            #         Description = "Home Manager System Tray";
            #         Requires = [ "graphical-session-pre.target" ];
            #     };
            # };
        };
    };
    flake.modules.homeManager.bt-applet = {
        pkgs,
        osConfig,
        ...
    }: {
        config = let
            inherit (osConfig.services) blueman;
        in {
            assertions = [
                {
                    assertion = blueman.enable;
                    message = ''
                        Blueman is required for the blueman applet. It is configured in nixos,
                                but is set to disabled semantically in the home-manager system_services module.
                                    Make sure blueman is configured and this options is set to true.
                    '';
                }
            ];
            services.blueman-applet = {
                enable = true;
            };
            # so that the commands are in the path
            home.packages = [
                pkgs.blueman
            ];
            # this creates the target for the system tray if needed. Should maybe be moved elsewhere
            # the applets services wont start without them
            # systemd.user.targets.tray = {
            #     Unit = {
            #         Description = "Home Manager System Tray";
            #         Requires = [ "graphical-session-pre.target" ];
            #     };
            # };
        };
    };
}
