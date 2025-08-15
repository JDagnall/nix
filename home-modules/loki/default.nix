{ pkgs, lib, config, inputs, ... }:
let inherit (lib) mkIf mkEnableOption;
in {
  options = {
    nixLoki.enable = mkEnableOption {
      default = false;
      description = "enable nixLoki nvim config";
    };
  };
  config = mkIf config.nixLoki.enable {
    home.packages = [
      # inputs.nixLoki.packages.x86_64-linux.nixLoki
      inputs.nixLoki.packages.x86_64-linux.testNixLoki
      pkgs.nixLoki
      # pkgs.testNixLoki
    ];

    home.sessionVariables = { EDITOR = "nixLoki"; };
  };
}
