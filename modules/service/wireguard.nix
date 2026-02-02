{
	pkgs,
	lib,
	config,
	...
}: {
	options = {
		service.wiregaurd = {
			enable = lib.mkEnableOption "Enable Wiregaurd config.";
			PIA = lib.mkEnableOption "Enable PIA wiregaurd config.";
		};
	};
	config = let
		listenPort = 1337;
	in
		lib.mkIf config.service.wiregaurd.enable {
			assertions = [
				{
					assertion = config.sops.enable;
					message = "Wireguard requires sops to be enabled to retrieve private keys.";
				}
			];
			sops.secrets = let
				host = config.networking.hostName;
			in
				lib.mkIf config.sops.enable {
					# "VPN/PIA/wiregaurd/public" = {
					# 	sopsFile = "../../secrets/${host}/vpn.yaml";
					# };
					"VPN/PIA/wiregaurd/private" =
						lib.mkIf config.service.wiregaurd.PIA {
							sopsFile = ../../secrets/${host}/vpn.yaml;
						};
				};
			environment.systemPackages = with pkgs; [wireguard-tools];
			networking.firewall.allowedUDPPorts = [listenPort];
			networking.wireguard.enable = true;
			networking.wg-quick.interfaces = {
				wgpiamel0 =
					lib.mkIf config.service.wiregaurd.PIA {
						type = "wireguard";
						address = ["10.100.0.2/24"];
						dns = ["10.0.0.243" "10.0.0.242"];
						privateKeyFile = config.sops.secrets."VPN/PIA/wiregaurd/private".path;
						autostart = false;
						listenPort = listenPort;
						peers = [
							{
								publicKey = "p3iGWV65zkQaB3FwcydcFOz/AtGqqSoIcJOrO749Pn0=";
								allowedIPs = ["0.0.0.0/0"];
								endpoint = "45.130.141.215:${builtins.toString listenPort}";
								persistentKeepalive = 25;
							}
						];
					};
				wgpiabne0 =
					lib.mkIf config.service.wiregaurd.PIA {
						type = "wireguard";
						address = ["10.100.0.3/24"];
						dns = ["10.0.0.243" "10.0.0.242"];
						privateKeyFile = config.sops.secrets."VPN/PIA/wiregaurd/private".path;
						autostart = false;
						listenPort = listenPort;
						peers = [
							{
								publicKey = "kTHBkpolHZaxgnaZ4xq3HEskikWlPfEtVUWt66kvCFs=";
								allowedIPs = ["0.0.0.0/0"];
								endpoint = "223.252.34.42:${builtins.toString listenPort}";
								persistentKeepalive = 25;
							}
						];
					};
			};
		};
}
