{
	pkgs,
	lib,
	config,
	osConfig,
	...
}: {
	options = {
		ui.obsidian.enable = lib.mkEnableOption {description = "Enable obsidian config.";};
	};
	config = let
		vaults =
			[]
			++ lib.optionals osConfig.service.syncthing.folders.classes.enable [
				{
					path = "${osConfig.services.syncthing.dataDir}/classes/obsidian";
					open = true; # default
				}
			];
		configJSON =
			(pkgs.formats.json {}).generate "obsidian.json" {
				vaults =
					builtins.listToAttrs (
						map (vault: {
								name = builtins.hashString "md5" vault.path;
								value = {
									path = vault.path;
									open = vault.open;
								};
							})
						vaults
					);
			};
	in
		lib.mkIf config.ui.obsidian.enable {
			# home-manager settings for obsidian are busted, so i'm doing the vault stuff myself
			# im overriding here
			xdg.configFile."obsidian/obsidian.json" = {
				source = lib.mkForce configJSON;
				force = true;
			};
			programs.obsidian = {
				enable = true;
				cli.enable = true;
			};
			stylix.targets.obsidian = {
				enable = true;
				vaultNames = [] ++ lib.optionals osConfig.service.syncthing.folders.classes.enable ["obsidian"];
			};
		};
}
