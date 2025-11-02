{
	pkgs,
	lib,
	config,
	...
}: let
	inherit (lib) mkIf mkOption mkEnableOption optionals;
in {
	options = {
		langs.lua.enable = mkEnableOption "lua";
		langs.lua.formatters =
			mkOption {
				type = lib.types.bool;
				default = true;
				description = "Include formatters in lua config.";
			};
	};
	config = let
		inherit (config.langs.lua) formatters;
	in
		mkIf config.langs.lua.enable {
			home.packages = with pkgs; [lua] ++ optionals formatters [stylua];
		};
}
