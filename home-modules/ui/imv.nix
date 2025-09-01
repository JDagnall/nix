{ lib, config, ... }:
{
    options = {
        ui.imv.enable = lib.mkEnableOption { description = "Enable imv image viewer config."; };
    };
    config = lib.mkIf config.ui.imv.enable {
        programs.imv = {
            enable = true;
            settings = {
                options = {
                    overlay = true;
                };
            };
        };
    };
}
