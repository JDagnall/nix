{ lib, config, ... }:
let inherit (lib) mkIf mkEnableOption;
in {
  options = {
    ui.waybar.enable = mkEnableOption {
      default = false;
      description = "Enable waybar config";
    };
  };
  config = mkIf config.ui.waybar.enable {
    programs.waybar = {
      enable = true;
      settings = { };
      style = "";
    };
  };
}
