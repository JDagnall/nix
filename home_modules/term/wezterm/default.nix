{ lib, config, ... }:
let
    inherit (lib) mkIf mkEnableOption;
in
{
    options = {
        term.wezterm.enable = mkEnableOption {
            default = false;
            description = "Enable wezterm config";
        };
    };
    config = mkIf config.term.wezterm.enable {
        programs.wezterm = {
            enable = true;
            enableZshIntegration = config.shell.zsh.enable;
            extraConfig = builtins.readFile ./wezterm.lua;
            # stylix
        };
    };
}
