{
    lib,
    self,
    ...
}: {
    flake.modules.homeManager.wezterm = {config, ...}: {
        imports = with self.modules.homeManager; [stylix-interface];
        options = {
            my.terminals.wezterm = {
                isDefaultTerm = lib.mkOption {
                    type = lib.types.bool;
                    default = true;
                    description = "Set TERMINAL session variable";
                };
            };
        };
        config = let
            cfg = config.my.terminals.wezterm;
        in {
            programs.wezterm = {
                enable = true;
                # enableZshIntegration =
                extraConfig = builtins.readFile ./wezterm.lua;
            };
            home.shellAliases = {
                wimg = "wezterm imgcat"; # easy alias for displaying images
            };
            home.sessionVariables.TERMINAL = lib.mkIf cfg.isDefaultTerm "wezterm";
            stylix.targets.wezterm.enable = config.my.stylix.enabled;
        };
    };
}
