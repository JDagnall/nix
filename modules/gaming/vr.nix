{...}: {
    flake.modules.nixos.alvr = {
        programs.alvr = {
            enable = true;
            openFirewall = true;
        };
    };
    flake.modules.nixos.wivrn = {
        pkgs,
        config,
        ...
    }: let
        compatlib = "xrizer";
        # compatlib = "opencomposite";
    in {
        config = {
            my.gaming.steam.extraEnv = {
                PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES = "1";
                VR_OVERRIDE = "${pkgs.${compatlib}}/lib/${compatlib}";
            };
            services.wivrn = {
                enable = true;
                # package = pkgs.wivrn;
                config = {
                    enable = true;
                    json = {
                        # encoder = [ # can manually configure encoders ];
                        openvr-compat-path = "${pkgs.${compatlib}}/lib/${compatlib}";
                        application = [pkgs.wayvr]; # start on connect
                    };
                };
                openFirewall = true;
                steam = {
                    enable = true;
                    importOXRRuntimes = true;
                    package = config.programs.steam.package;
                };
                monadoEnvironment = {
                    STEAMVR_LH_ENABLE = "1";
                    XRT_COMPOSITOR_COMPUTE = "1";
                    WMR_HANDTRACKING = "0";
                };
                highPriority = true; # adds CAP_SYS_NICE
                # I wanna start this manually
                autoStart = false;
            };
            environment.systemPackages = config.gaming.vr.wivrn.enable [
                pkgs.${compatlib}
            ];
        };
    };
}
