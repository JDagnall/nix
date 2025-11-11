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
						updateResolvConf = true;
					};
					PIA-Brisbane = {
						config = ''config ${builtins.toString ./servers/PIA_brisbane.ovpn}'';
						autoStart = false;
						updateResolvConf = true;
					};
					PIA-Sydney = {
						config = ''config ${builtins.toString ./servers/PIA_sydney.ovpn}'';
						autoStart = false;
						updateResolvConf = true;
					};
				};
			};
			networking.networkmanager.plugins =
				lib.mkIf config.networking.networkmanager.enable [
					pkgs.networkmanager-openvpn
				];
		};
}
