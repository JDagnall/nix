{
	lib,
	config,
	...
}: let
	inherit (lib) mkIf mkEnableOption;
in {
	options = {
		term.wezterm = {
			enable = mkEnableOption "Enable wezterm config";
			default =
				lib.mkOption {
					type = lib.types.bool;
					default = true;
					description = "Set TERMINAL session variable";
				};
		};
	};
	config =
		mkIf config.term.wezterm.enable {
			programs.wezterm = {
				enable = true;
				enableZshIntegration = config.shell.zsh.enable;
				extraConfig = builtins.readFile ./wezterm.lua;
			};
			home.sessionVariables.TERMINAL = "wezterm";
			stylix.targets.wezterm.enable = config.stylix.enableHomeConfig;
		};
}
