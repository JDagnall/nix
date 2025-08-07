{
# pkgs,
lib, config, ... }:
let inherit (lib) mkIf mkEnableOption mkForce;
in {
  options = {
    shell.eza.enable = mkEnableOption {
      default = false;
      description = "enable eza config";
    };
  };
  config = mkIf config.shell.eza.enable {
    programs.eza = {
      enable = true;
      enableZshIntegration = config.shell.zsh.enable;
      extraOptions = [ "--long" "--all" ];
      git = true;
      icons = "auto";
      # theme = {}
    };
    programs.zsh.shellAliases = mkIf config.shell.zsh.enable {
      ls = mkForce "eza";
      lt = "eza --tree --level 3 -I .git";
    };
  };

}
