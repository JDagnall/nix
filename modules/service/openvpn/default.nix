{
	pkgs,
	lib,
	config,
	...
}: {
	options = {
		service.openvpn.enable = lib.mkEnableOption {description = "Enable openvpn config";};
	};
	config =
		lib.mkIf config.service.openvpn.enable {
			services.openvpn = {
				restartAfterSleep = true;
				# these get turned into system services
				servers = {
					PIA-Melbourne = {
						config = ''config ${builtins.toString ./servers/PIA_melbourne.ovpn}'';
						autoStart = false;
						updateResolvConf = false;
					};
					PIA-Sydney = {
						config = ''config ${builtins.toString ./servers/PIA_sydney.ovpn}'';
						autoStart = false;
						updateResolvConf = false;
					};
				};
			};
			networking.networkmanager.plugins =
				lib.mkIf config.networking.networkmanager.enable [
					pkgs.networkmanager-openvpn
				];
		};
}
