{
	lib,
	config,
	...
}: {
	options = {
		service.avahi.enable = lib.mkEnableOption "Enable avahi, which enables mDNS.";
	};
	config =
		lib.mkIf config.service.avahi.enable {
			services.avahi = {
				enable = true;
				openFirewall = true;
				hostName = config.networking.hostName;
				# ipv4 = ;
				# ipv6 = ;
				# nssmdns4 = ;
				# nssmdns6 = ;
				publish = {
					# enable = ;
					# domain = ;
					# hinfo = ;
					# userServices = ;
					# workstation = ;
				};
				# extraConfig = "";
				# extraServiceFiles = {};
				domainName = "local"; # hostname.[domainName]
				# denyInterfaces = [];
				# browseDomains = [];
				allowPointToPoint = false;
				# reflector = ;
				# wideArea = ;
			};
		};
}
