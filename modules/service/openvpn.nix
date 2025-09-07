{
	lib,
	config,
	...
}: {
	options = {
		service.openvpn3.enable = lib.mkEnableOption {default = "Enable openvpn config";};
	};
	config =
		lib.mkIf config.service.openvpn3.enable {
			programs.openvpn3 = {
				enable = true;
			};
		};
}
