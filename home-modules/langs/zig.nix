# this is definetly bad and I should not use this. use dev shells instead.
{
	pkgs,
	lib,
	config,
	...
}: let
	inherit (lib) mkIf mkOption mkEnableOption optionals;
in {
	options = {
		langs.zig.enable = mkEnableOption "zig";
		# zig comes with a formatter
		# langs.zig.formatters =
		# 	mkOption {
		# 		type = lib.types.bool;
		# 		default = true;
		# 		description = "Include formatters in zig config.";
		# 	};
	};
	config =
		mkIf config.langs.zig.enable {
			home.packages = with pkgs; [zig_0_15];
		};
}
