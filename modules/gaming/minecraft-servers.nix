{
	pkgs,
	lib,
	config,
	...
}: {
	options = {
		gaming.minecraft-servers = {
			enable = lib.mkEnableOption "Enable minecraft servers configuration";
			"1.18.2" = lib.mkEnableOption "Enable 1.18.2 server";
			"1.21.4" = lib.mkEnableOption "Enable 1.21.4 server";
			"1.21.10" = lib.mkEnableOption "Enable 1.21.10 server";
		};
	};
	# very annoying hack, using mkIf here will cause an error if the overlay is not loaded, because it will still evaluate the set
	# causes an error even though the setting is not enabled
	config =
		lib.mkIf config.gaming.minecraft-servers.enable {
			services.minecraft-servers = {
				enable = true;
				eula = true;

				# the defaults
				dataDir = "/srv/minecraft";
				user = "minecraft";
				group = "minecraft";

				servers = {
					"1.18.2" = {
						enable = config.gaming.minecraft-servers."1.18.2";
						# can select the loader version here with .override { loaderVersion = ""; };
						package = pkgs.fabricServers.fabric-1_18_2;
						serverProperties = {
							server-port = 25565;
						};
						openFirewall = true;
						whitelist = {};
						symlinks = {
							# could link to an actual folder here
							# "mods = ./mods"

							# could also build a mods folder from links to mods
							# this builds a folder of symlinks to the mod files fetched.
							# the bultins.attrValues creats a list of just the derivation fetched by fetchurl
							# the attr names are just for documentation / readability
							"mods" =
								pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
										carpet =
											pkgs.fetchurl {
												url = "https://cdn.modrinth.com/data/TQTTVgYE/versions/Gt4ohwGH/fabric-carpet-1.18.2-1.4.69%2Bv220331.jar";
												hash = "sha256-/gubc4SNyVzdtmPG9Vfk1uWcEO5foHIOu0o5ln0N4mU=";
												name = "fabric-carpet-1.18.2.jar";
											};
									});
						};
					};
					"1.21.4" = {
						enable = config.gaming.minecraft-servers."1.21.4";
						package = pkgs.fabricServers.fabric-1_21_4;
						serverProperties = {
							server-port = 25565;
						};
						openFirewall = true;
						whitelist = {};
						symlinks = {
							"mods" =
								pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
										carpet =
											pkgs.fetchurl {
												url = "https://cdn.modrinth.com/data/TQTTVgYE/versions/aVB2lYQQ/fabric-carpet-1.21.4-1.4.161%2Bv241203.jar";
												hash = "sha256-AxFO/ZnFl6Y4ZD2OuXt9xIUxjAB3UHddil6MhmtE7XY=";
												name = "fabric-carpet-1.21.4.jar";
											};
									});
						};
					};
					"1.21.10" = {
						enable = config.gaming.minecraft-servers."1.21.10";
						package = pkgs.fabricServers.fabric-1_21_10;
						serverProperties = {
							server-port = 25565;
							level-seed = 6586346193942;
						};
						openFirewall = true;
						whitelist = {};
						symlinks = {
							"mods" =
								pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
										servux =
											pkgs.fetchurl {
												url = "https://cdn.modrinth.com/data/zQhsx8KF/versions/4NqOw9an/servux-fabric-1.21.10-0.8.3.jar";
												sha256 = "1cyxys1g3s268frn5mjliahnh2ybhp4i0265himfa09p76wh5837";
											};
									});
						};
					};
				};
			};
		};
}
