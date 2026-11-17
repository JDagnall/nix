{self, ...}: {
    flake.modules.nixos.orion = {...}: {
        imports = with self.modules.nixos; [dns dnsmasqServer];
        config = {
            my.services.dns = {
                entries = [
                    {
                        ip = "100.121.250.78";
                        domain = "home.waluigimangione.dev";
                    }
                ];
            };
            my.servers.dns = {
                openFirewall = true;
            };
        };
    };
}
