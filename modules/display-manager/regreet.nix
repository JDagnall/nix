{
    pkgs,
    lib,
    config,
    ...
}: let
    cfg = config.display-manager.regreet;
in {
    options = {
        display-manager.regreet = {
            enable = lib.mkEnableOption "Enable regreet";
        };
    };

    config = lib.mkIf cfg.enable {
        services.displayManager.regreet = {
            enable = true;
            settings = {};
        };
        # backend for regreet
        services.greetd = {
            enable = true;
            settings = {
                # changing the backend compositor for regreet to a more modern one that
                # can handle multiple monitors
                default_session = {
                    command = let
                        swayCfg = pkgs.writeText "regreet-sway-cfg" ''
                            # output * scale 1 # dont scale
                            exec "${lib.getExe pkgs.regreet}; ${pkgs.sway}/bin/swaymsg exit"
                            include /etc/sway/config.d/* # I have no idea what this is needed for
                        '';
                    in "${lib.getExe pkgs.sway} --config ${swayCfg}";
                };
            };
        };
        stylix.targets.regreet.enable = config.stylix.enableConfig;
    };
}
