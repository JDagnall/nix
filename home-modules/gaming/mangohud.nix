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
				settings = {
					# legacy_layout = 2;
					gpu_name = true;
					gpu_list = [0];
					gpu_temp = true;
					cpu_temp = true;
					cpu_load = true;
					vram = true;
					ram = true;
					fps = true;
					frame_timing = 0;
					wine = true;
					gamemode = true;
					graphs = "";

					round_corners = 0.5;
					horizontal = true;
					# override some of stylix's bad decisions
					background_alpha = lib.mkForce 0.5;
					alpha = lib.mkForce 0.8;
				};
				settingsPerApplication = {};
			};
			stylix.targets.mangohud.enable = config.stylix.enableHomeConfig;
		};
}
