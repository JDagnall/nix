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
                # Allows Monado/WiVRn to be used
                extraProfile = lib.optionalString config.gaming.vr.wivrn.enable ''
                    export PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
                '';
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
