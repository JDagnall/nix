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
        config = let
            # cfg = config.my.gaming.vr;
        in {
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
            environment.systemPackages = [
                pkgs.${compatlib}
            ];
        };
    };

    flake.modules.homeManager.wivrn = {pkgs, ...}: {
        xdg.configFile = {
            "openxr/1/active_runtime.json".source = "${pkgs.wivrn}/share/openxr/1/openxr_wivrn.json";
            # wivrn does this now
            # "openvr/openvrpaths.vrpath".text = let
            #     steamDir = "${config.xdg.dataHome}/Steam";
            #     compat = osConfig.gaming.vr.wivrn.compatLib;
            # in
            #     builtins.toJSON {
            #         version = 1;
            #         jsonid = "vrpathreg";
            #         external_drivers = null;
            #         config = ["${steamDir}/config"];
            #         log = ["${steamDir}/logs"];
            #         runtime = [
            #             "${pkgs.${compat}}/lib/${compat}"
            #         ];
            #     };
        };
    };
}
