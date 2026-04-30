{
	pkgs,
	lib,
	config,
	osConfig,
	...
}: {
	options = {
		gaming.lutris.enable =
			lib.mkEnableOption {
				description = "Enable lutris, a launcher for games.";
			};
	};
	config =
		lib.mkIf config.gaming.lutris.enable {
			programs.lutris = {
				enable = true;
				# a lutris dependency openldap currently has a problem,
				# with failing tests. overriding this here to turn this off
				package =
					pkgs.lutris.override {
						# intercept buildFHSEnv to turn off checks for openldap
						buildFHSEnv = args:
							pkgs.buildFHSEnv (args
								// {
									multiPkgs = envPkgs: let
										originalPkgs = args.multiPkgs envPkgs;
										customLdap = envPkgs.openldap.overrideAttrs (_: {doCheck = false;});
									in
										# replace broken openldap with version ammended to not run tests
										builtins.filter (p: (p.pname or "") != "openldap") originalPkgs ++ [customLdap];
								});
					};
				extraPackages = with pkgs; [flatpak];
				defaultWinePackage = pkgs.proton-ge-bin;
				protonPackages = [pkgs.proton-ge-bin];
				winePackages = [];
				runners = {
					# eg = {
					# 	package = pkg;
					# 	settings = {
					# 		system = {};
					# 	};
					#                 runner = {};
					# };
				};
				steamPackage = osConfig.programs.steam.package;
			};
		};
}
