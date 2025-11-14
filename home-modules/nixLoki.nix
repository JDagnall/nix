{
	# pkgs,
	lib,
	config,
	inputs,
	...
}: let
	inherit (lib) mkIf mkEnableOption mkOption;
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
		};
	};
	# required for the home manager modules exported by nixLoki to be available in the namespace
	imports = [inputs.nixLoki.homeModule];
	config =
		mkIf nixLoki.enable {
			assertions = [
				{
					assertion =
						(
							(nixLoki.theme == "tinted-nvim" || nixLoki.theme == "mini-base16")
							&& stylix.enable
							&& stylix.enableHomeConfig
						)
						|| (nixLoki.theme != "mini-base16" && nixLoki.theme != "tinted-nvim");
					message = "Using mini-base16 or tinted-nvim with nixLoki requires stylix and for it to be enabled in home manager.";
				}
			];
			programs.nixLoki = {
				enable = true;
				# nixLoki packages to install
				packageNames = ["nixLoki" "testNixLoki"];
				packageDefinitions = {
					# this merges into the package config for nixLoki
					merge = let
						# the values being overrided in the nixLoki config to set the theme and provide base16 colours
						base16Overrides = {pkgs, ...}: {
							categories = {
								"${nixLoki.theme}" = lib.mkForce true;
							};
							extra = {
								# gets every stylix base16 colour into a set that lua will be able to digest in the nixLoki flake
								base16Colours = pkgs.lib.filterAttrs (k: v: (builtins.match "base0[0-9A-F]" k) != null) config.lib.stylix.colors.withHashtag;
							};
						};
					in {
						nixLoki = base16Overrides;
						testNixLoki = base16Overrides;
					};
				};
			};

			home.sessionVariables = {EDITOR = "nixLoki";};
		};
}
