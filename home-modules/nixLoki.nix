{
	# pkgs,
	lib,
	config,
	inputs,
	...
}: let
	inherit (lib) mkIf mkEnableOption mkOption optionalAttrs;
	inherit (config) nixLoki stylix;
in {
	options = {
		nixLoki = {
			enable =
				mkEnableOption {
					default = false;
					description = "enable nixLoki nvim config";
				};
			theme =
				mkOption {
					default = "catppuccin";
					type = lib.types.enum ["catppuccin" "mini-base16" "tinted-nvim"];
					description = "The plugin to nixLoki nvim with, mini-base16 and tinted-nvim use stylix.";
				};
			enableWezterm =
				mkOption {
					default = config.programs.wezterm.enable;
					type = lib.types.bool;
					description = "Enable the wezterm integration";
				};
		};
	};
	# required for the home manager modules exported by nixLoki to be available in the namespace
	imports = [inputs.nixLoki.homeModule];
	config =
		mkIf nixLoki.enable {
			assertions = [
				{
					assertion =
						stylix.enable
						|| (nixLoki.theme != "mini-base16" && nixLoki.theme != "tinted-nvim");
					message = "Using mini-base16 or tinted-nvim with nixLoki requires stylix.";
				}
			];
			programs.nixLoki = {
				enable = true;
				# nixLoki packages to install
				packageNames = ["nixLoki" "testNixLoki"];
				packageDefinitions = {
					# this merges into the package config for nixLoki
					merge = let
						# the values being added to the nixLoki config to set the theme and provide base16 colours
						values = {pkgs, ...}:
							{
								categories = {
									"${nixLoki.theme}" = true;
								};
							}
							// optionalAttrs stylix.enable {
								extra = {
									# gets every stylix base16 colour into a set that lua will be able to digest in the nixLoki flake
									base16Colours = pkgs.lib.filterAttrs (k: v: (builtins.match "base0[0-9A-F]" k) != null) config.lib.stylix.colors.withHashtag;
								};
							};
					in {
						testNixLoki = values;
						nixLoki = values;
					};
					replace = let
						# the values being overrided in the nixLoki config
						overrides = {...}: {
							categories = {
								wezterm = nixLoki.enableWezterm;
							};
						};
					in {
						testNixLoki = overrides;
						nixLoki = overrides;
					};
				};
			};

			home.sessionVariables = {EDITOR = "nixLoki";};
		};
}
