{
	pkgs,
	lib,
	config,
	...
}: {
	options = {
		gaming.vr.enable = lib.mkEnableOption "Enable WiVRn, a wireless VR streamer";
		gaming.vr.wivrn.enable = lib.mkEnableOption "Enable WiVRn, a wireless VR streamer";
	};
	config =
		lib.mkIf config.gaming.vr.enable {
			services.wivrn =
				lib.mkIf config.gaming.vr.wivrn.enable {
					enable = true;
					# package =
					config = {
						enable = true;
						json = {
							# encoder = [ # can manually configure encoders
							# ];
							application = [pkgs.wayvr];
						};
					};
					openFirewall = true;
					defaultRuntime = true;
					steam = {
						importOXRRuntimes = true;
						package = config.programs.steam.package;
					};
					monadoEnvironment = {};
					highPriority = true; # high prio capability for async reprojection ?????
					# I wanna start this manually
					autoStart = false;
				};
		};
}
