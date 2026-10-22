{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.avahi-interface = {...}: {
        key = "my/nixos/avahi-interface";
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
                # ipv4 = ;
                # ipv6 = ;
                nssmdns4 = true;
                nssmdns6 = true;
                settings = {
                    server = {
                        host-name = config.networking.hostName;
                        domain-name = "local"; # hostname.[domainName]
                        # browse-domains = false;
                        # deny-interfaces = [];
                        allow-point-to-point = false;
                    };
                    publish = {
                        disable-publishing = false;
                        publish-addresses = true;
                        publish-domain = false;
                        publish-hinfo = true;
                        disable-user-service-publishing = false;
                        publish-workstation = true;
                    };
                    # reflector = {
                    #     enable-reflector = true;
                    # };
                };
                # extraConfig = "";
                # extraServiceFiles = {};
                # wideArea = ;
            };
        };
    };
}
