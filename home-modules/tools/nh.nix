{
	lib,
	config,
	...
}: {
	options = {
		tools.nh.enable =
			lib.mkEnableOption {
				description = "Enable nh config. A cli helper for managing nix";
			};
	};
	config =
		lib.mkIf config.tools.nh.enable {
			programs.nh = {
				enable = true;
				# should be unneccesary to set any other default flakes as i'm using home-manager
				# as a module
				osFlake = "/home/james/nix";
				# supposedly better than nix-collect-garbage, but havent switched yet
				clean = {
					enable = false;
					dates = "weekly";
					extraArgs = "--keep 5 --keep-since 3d";
				};
			};
		};
}
