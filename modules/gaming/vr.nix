{
    pkgs,
    lib,
    config,
    ...
}: {
    options = {
        gaming.vr.enable = lib.mkEnableOption "Enable VR configuration";
        gaming.vr.wivrn = {
            enable = lib.mkEnableOption "Enable WiVRn, a wireless VR streamer";
            compatLib = lib.mkOption {
                default = "xrizer";
                type = lib.types.enum ["xrizer" "opencomposite"];
                description = "The compatability library to use for openVR.";
            };
        };

        gaming.vr.alvr.enable = lib.mkEnableOption "Enable ALVR, a wireless VR streamer";
    };
    config = let
    in
        lib.mkIf config.gaming.vr.enable {
            services.wivrn = lib.mkIf config.gaming.vr.wivrn.enable {
                enable = true;
                # package = pkgs.wivrn;
                config = {
                    enable = true;
                    json = let
                        compat = config.gaming.vr.wivrn.compatLib;
                    in {
                        # encoder = [ # can manually configure encoders ];
                        # openvr-compat-path = "${pkgs.${compat}}/lib/${compat}";
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
            environment.systemPackages = lib.mkIf config.gaming.vr.wivrn.enable [
                pkgs.${config.gaming.vr.wivrn.compatLib}
            ];
            programs.alvr = lib.mkIf config.gaming.vr.alvr.enable {
                enable = true;
                openFirewall = true;
            };
        };
}
