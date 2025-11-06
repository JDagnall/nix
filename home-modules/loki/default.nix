{
	pkgs,
	lib,
	config,
	# inputs,
	...
}: let
	inherit (lib) mkIf mkEnableOption;
	inherit (config) nixLoki stylix;
in {
	options = {
		nixLoki = {
			enable =
				mkEnableOption {
					default = false;
					description = "enable nixLoki nvim config";
				};
			useBase16 = mkEnableOption "Enable base 16 styling for nixLoki using stylix and mini-base16";
		};
	};
	config =
		mkIf nixLoki.enable {
			assertions = [
				{
					assertion = (nixLoki.useBase16 && stylix.enable && stylix.enableHomeConfig) || !nixLoki.useBase16;
					message = "Using base 16 with nixLoki requires stylix and for it to be enabled in home manager.";
				}
			];
			home.packages = [
				# 	inputs.nixLoki.packages.x86_64-linux.nixLoki
				# 	inputs.nixLoki.packages.x86_64-linux.testNixLoki
				pkgs.nixLoki
				pkgs.testNixLoki
			];
			# nixLoki = {
			# 	# enable = true;
			# 	packageDefinitions = {
			# 		# nixLoki packages to install
			# 		packageNames = ["nixLoki" "testNixLoki"];
			# 		# this merges into the package config for nixLoki
			# 		merge = let
			# 			# the values being overrided in the nixLoki config to enable base16
			# 			base16Overrides = {
			# 				categories = {
			# 					catppuccin = lib.mkForce false;
			# 					mini-base16 = lib.mkForce true;
			# 				};
			# 				extra = {
			# 					# gets every stylix base16 colour into a set that lua will be able to digest in the nixLoki flake
			# 					base16Colors = pkgs.lib.filterAttrs (k: v: (builtins.match "base0[0-9A-F]" k) != null) config.lib.stylix.colors.withHashtag;
			# 				};
			# 			};
			# 		in
			# 			lib.mkIf stylix.enableHomeConfig
			# 			&& nixLoki.useBase16 {
			# 				nixLoki = base16Overrides;
			# 				testNixLoki = base16Overrides;
			# 			};
			# 	};
			# };

			home.sessionVariables = {EDITOR = "nixLoki";};
		};
}
