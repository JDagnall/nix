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
	config = let
		# getting an old nixpkgs-unstable where the wayvr version is one down "26.2" to prevent an screen stretching issue
		# will be able to remove this soon when the WiVRn and Monado packages in nixpkgs catch up
		# see here https://github.com/wlx-team/wayvr/issues/441
		pkgsWithOldWayvr =
			import (fetchTree {
					type = "github";
					owner = "nixos";
					repo = "nixpkgs";
					rev = "d26a1a9e5e2a286f8a16f1abfbaf184e577febe3";
				}) {inherit (pkgs) system;};
	in
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
							openvr-compat-path = "${pkgs.xrizer}/lib/xrizer";
							application = [pkgsWithOldWayvr.wayvr]; # start on connect
						};
					};
					openFirewall = true;
					steam = {
						importOXRRuntimes = true;
						package = config.programs.steam.package;
					};
					monadoEnvironment = {
						STEAMVR_LH_ENABLE = "1";
						XRT_COMPOSITOR_COMPUTE = "1";
					};
					highPriority = true; # high prio capability for async reprojection ?????
					# I wanna start this manually
					autoStart = false;
				};
		};
}
