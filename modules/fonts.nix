{ pkgs, lib, config, ... }:
let inherit (lib) mkIf mkEnableOption;
in {
  options = {
    fonts.enable = mkEnableOption {
      default = false;
      description = "Enable default fonts and setting the default font";
    };
  };
  config = mkIf config.fonts.enable {
    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [ nerd-fonts.victor-mono nerd-fonts.fira-code ];
      fontconfig = { defaultFonts = { monospace = [ "Victor Mono" ]; }; };
    };
  };
}
