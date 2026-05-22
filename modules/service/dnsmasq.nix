{
	lib,
	config,
	...
}: {
	options = {
		service.dnsmasq = {
			enable = lib.mkEnableOption "Enable dnsmasq, a DNS server only intended for use within a local network.";
			network-interfaces =
				lib.mkOption {
					description = "List of network interfaces to listen on. Will add tailscale to the list automatically if its enabled.";
					default = [] ++ lib.optionals config.service.tailscale.enable ["tailscale0"];
					type = lib.types.listOf lib.types.str;
				};
		};
	};
	config = let
		host = config.networking.hostName;
	in
		lib.mkIf config.service.dnsmasq.enable {
			services.dnsmasq = {
				enable = true;
				resolveLocalQueries = true;
				settings = {
					address = [
						# create dns entry for this device, networks utilising this server should be able to easily navigate to this device
						"/${host}.home/127.0.0.1"
						"/*.${host}.home/127.0.0.1"
					];
					interface = config.service.dnsmasq.network-interfaces;
					server = ["1.1.1.1" "8.8.8.8"]; # cludflare and google
				};
			};
		};
}
