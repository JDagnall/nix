{self, ...}: let
    deviceSettings = {
        my.services.syncthing.devices.orion = {
            id = "LUNWAUX-SIKFQ5O-PDYIJW7-3DCCK2A-ZAGF4M2-MR2XTCL-UNNA2O4-CEZLDQX";
            connectOverTailscale = true;
            tailscaleHostName = "pc";
        };
    };
    # TODO: putting this here for now, would need a general or common place to put this?
    galaxyDeviceSettings = {
        my.services.syncthing.devices.galaxy = {
            id = "NYORDT7-6IUBNB6-7DGXYQA-TK2TZLW-YJYDBOK-E3PISCB-PIHPSAA-EQI7VQI";
            connectOverTailscale = true;
            tailscaleHostName = "samsung-s10e";
        };
    };
in {
    flake.modules.nixos.syncthing.orion = deviceSettings;
    flake.modules.home.syncthing.orion = deviceSettings;
    flake.modules.nixos.syncthing.galaxy = galaxyDeviceSettings;
    flake.modules.home.syncthing.galaxy = galaxyDeviceSettings;
    flake.modules.nixos.orion = {
        imports = with self.modules.nixos; [syncthing syncthing.pc syncthing.framework syncthing.book syncthing.galaxy];
        config = {
            my = {
                services.syncthing.folders = {
                    secure = {
                        id = "26bfd-pbgoj";
                        devices = ["pc" "framework" "book" "galaxy"];
                    };
                    classes = {
                        id = "9j26s-pweyy";
                        devices = ["pc" "framework"];
                    };
                    proj = {
                        id = "jwvcx-y7w2m";
                        devices = ["pc" "framework"];
                    };
                    wallpapers = {
                        id = "vjhql-ghx7b";
                        devices = ["pc" "framework"];
                    };
                    docs = {
                        id = "pysjc-vrzgj";
                        devices = ["pc" "framework" "galaxy"];
                    };
                };
            };
        };
    };
}
