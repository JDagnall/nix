{self, ...}: let
    deviceSettings = {
        my.services.syncthing.devices.orion = {
            id = "QQCYANM-MSTQWN3-VPYALHR-XXCWM6V-MU37PWP-VSDOY7F-BSWJFDH-Y4JBXQB";
            connectOverTailscale = true;
            tailscaleHostName = "orion";
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
    flake.modules.nixos.syncthing-orion = deviceSettings;
    flake.modules.homeManager.syncthing-orion = deviceSettings;
    flake.modules.nixos.syncthing-galaxy = galaxyDeviceSettings;
    flake.modules.homeManager.syncthing-galaxy = galaxyDeviceSettings;
    flake.modules.nixos.orion = {
        imports = with self.modules.nixos; [syncthing syncthing-server syncthing-sirius syncthing-lavos syncthing-dante syncthing-galaxy syncthing-dagath];
        config = {
            my = {
                services.syncthing.folders = {
                    secure = {
                        id = "26bfd-pbgoj";
                        devices = ["sirius" "lavos" "dante" "galaxy" "dagath"];
                    };
                    classes = {
                        id = "9j26s-pweyy";
                        devices = ["sirius" "lavos"];
                    };
                    proj = {
                        id = "jwvcx-y7w2m";
                        devices = ["sirius" "lavos"];
                    };
                    wallpapers = {
                        id = "vjhql-ghx7b";
                        devices = ["sirius" "lavos"];
                    };
                    docs = {
                        id = "pysjc-vrzgj";
                        devices = ["sirius" "lavos" "galaxy"];
                    };
                };
            };
        };
    };
}
