{
	lib,
	config,
	...
}: {
	options = {
		service.jellyfin.enable = lib.mkEnableOption "Enable jellyfin server config.";
	};
	config =
		lib.mkIf config.service.jellyfin.enable {
			services.jellyfin = {
				enable = true;
				openFirewall = true;
			};
		};
}
