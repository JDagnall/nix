{
	lib,
	config,
	...
}: {
	options = {
		service.dnsmasq = {
			enable = lib.mkEnableOption "Enable dnsmasq, a DNS server only intended for use within a local network.";
			localNetworkInterface =
				lib.mkOption {
					description = "Network interfaces to listen on for the local network.";
					default = "eth0";
					type = lib.types.str;
				};
			tailscaleNetworkInterface =
				lib.mkOption {
					description = "Tailscale interfaces to listen on for the tailscale network.";
					default = "tailscale0";
					type = lib.types.str;
				};
		};
	};
	config = let
		host = config.networking.hostName;
		localInterface = config.service.dnsmasq.localNetworkInterface;
		tailscaleInterface = config.service.dnsmasq.tailscaleNetworkInterface;
	in
		lib.mkIf config.service.dnsmasq.enable {
			services.dnsmasq = {
				enable = true;
				resolveLocalQueries = true;
				settings = {
					address = [];
					# create dns entry for this device, networks utilising this server should be able to easily navigate to this device
					interface-name =
						[
							"${host}.home,${localInterface}"
							"*.${host}.home,${localInterface}"
						]
						++ lib.optionals config.service.tailscale.enable [
							"${host}.tail,${tailscaleInterface}"
							"*.${host}.tail,${tailscaleInterface}"
						];
					interface = [localInterface] ++ lib.optionals config.service.tailscale.enable [tailscaleInterface];
					server = ["1.1.1.1" "8.8.8.8"]; # cloudflare and google, not really needed
				};
			};
		};
}
