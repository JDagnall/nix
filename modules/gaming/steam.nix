{
	pkgs,
	lib,
	config,
	...
}: {
	options = {
		gaming.steam.enable =
			lib.mkEnableOption {
				description = "Enable steam.";
			};
	};
	config =
		lib.mkIf config.gaming.steam.enable {
			programs.steam = {
				enable = true;
				protontricks.enable = false;
				gamescopeSession = {
					enable = true;
					# env = {};
					# args = [];
					# steamArgs = [];
				};
				extraPackages = with pkgs; [mangohud]; # preformance monitor
				extraCompatPackages = [];
				extest.enable = false;
				localNetworkGameTransfers.openFirewall = false;
				remotePlay.openFirewall = false;
				dedicatedServer.openFirewall = false;
			};
			# important optimisations
			programs.gamemode.enable = true;
		};
}
