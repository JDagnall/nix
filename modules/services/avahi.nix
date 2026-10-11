{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.avahi-interface = {...}: {
        options.my = {
            services.avahi.enabled = lib.mkEnableOption "Avahi is enabled.";
        };
    };
    flake.modules.nixos.avahi = {config, ...}: {
        imports = with self.modules.nixos; [avahi-interface];
        config = {
            services.avahi = {
                enable = true;
                openFirewall = true;
                hostName = config.networking.hostName;
                # ipv4 = ;
                # ipv6 = ;
                nssmdns4 = true;
                nssmdns6 = true;
                publish = {
                    enable = true;
                    domain = true;
                    hinfo = true;
                    userServices = true;
                    workstation = true;
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
    };
}
