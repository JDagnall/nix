# this is definetly bad and I should not use this. use dev shells instead.
# having python in user space is handy, but I should use dev shells for projects
{
	pkgs,
	lib,
	config,
	...
}: let
	inherit (lib) mkIf mkEnableOption mkOption optionals;
in {
	options = {
		langs.python.enable =
			mkEnableOption {
				default = false;
				description = "Enable python, installs 3.12.";
			};
		langs.python.formatters =
			mkOption {
				default = true;
				type = lib.types.bool;
				description = "Installs a few formatters.";
			};
		langs.python.packages =
			mkOption {
				default = true;
				type = lib.types.bool;
				description = "Installs some often used packages.";
			};
		langs.python.utils =
			mkOption {
				default = true;
				type = lib.types.bool;
				description = "Installs some often used python utilities.";
			};
	};
	config = let
		inherit (config.langs.python) formatters packages utils;
		formatterList = with pkgs; [
			ruff
			python312Packages.autopep8
		];
		packageList = with pkgs.python312Packages; [
			matplotlib
			pandas
			requests
		];
		utilList = with pkgs; [pipenv uv];
	in
		mkIf config.langs.python.enable {
			home.packages = with pkgs;
				[
					python312
					# python314 # multiple python versions cause collisions
				]
				++ optionals packages packageList
				++ optionals formatters formatterList
				++ optionals utils utilList;
		};
}
