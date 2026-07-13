{
    pkgs,
    lib,
    config,
    ...
}: {
    options = {
        gaming.steam.enable = lib.mkEnableOption {
            description = "Enable steam.";
        };
    };
    config = lib.mkIf config.gaming.steam.enable {
        allowedUnfreePkgNames = ["steam" "steam-unwrapped"];
        programs.steam = {
            enable = true;
            package = pkgs.steam.override {
                extraBwrapArgs = ["--bind ${pkgs.xrizer} ${pkgs.xrizer}"];
                extraEnv = let
                    compat = config.gaming.vr.wivrn.compatLib;
                in
                    lib.mkIf config.gaming.vr.wivrn.enable {
                        PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES = "1";
                        VR_OVERRIDE = "${pkgs.${compat}}/lib/${compat}";
                    };
            };
            protontricks.enable = false;
            gamescopeSession = {
                enable = true;
                # env = {};
                # args = [];
                # steamArgs = [];
            };
            extraPackages = with pkgs; [mangohud]; # preformance monitor
            extraCompatPackages = [];
            extest.enable = false;
            localNetworkGameTransfers.openFirewall = false;
            remotePlay.openFirewall = false;
            dedicatedServer.openFirewall = false;
        };
        hardware.graphics = {
            extraPackages = [pkgs.mangohud];
            extraPackages32 = [pkgs.mangohud];
        };
    };
}
