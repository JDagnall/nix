{
	# pkgs,
	lib,
	config,
	...
}: {
	options = {
		gaming.mangohud.enable =
			lib.mkEnableOption {
				description = "Enable mangohud config. Already installed with steam as a dependency.";
			};
	};
	config =
		lib.mkIf config.gaming.mangohud.enable {
			programs.mangohud = {
				enable = true;
				enableSessionWide = true;
				# override some of stylix's bad decisions
				settings =
					lib.mkForce {
						# legacy_layout = 2;
						gpu_name = true;
						gpu_temp = true;
						cpu_temp = true;
						cpu_load = true;
						vram = true;
						ram = true;
						fps = true;
						wine = true;
						gamemode = true;
						graphs = "";

						round_corners = 0.5;
						horizontal = true;
						background_alpha = 0.5;
						alpha = 0.8;
					};
				settingsPerApplication = {};
			};
			stylix.targets.mangohud.enable = config.stylix.enableHomeConfig;
		};
}
