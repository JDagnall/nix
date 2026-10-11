{lib, ...}: {
    flake.modules.nixos.steam = {
        pkgs,
        config,
        ...
    }: let
        cfg = config.myConfig.gaming.steam;
    in {
        options = {
            myConfig.gaming.steam.extraEnv = lib.mkOption {
                type = with lib.types; attrsOf str;
                default = {};
                description = "Environment variables to add to the steam runtime.";
            };
        };
        config = {
            allowedUnfreePkgNames = ["steam" "steam-unwrapped"];
            programs.steam = {
                enable = true;
                package = pkgs.steam.override {
                    extraBwrapArgs = ["--bind ${pkgs.xrizer} ${pkgs.xrizer}"];
                    extraEnv = cfg.extraEnv;
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
    };
}
