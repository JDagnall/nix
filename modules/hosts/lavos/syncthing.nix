{self, ...}: let
    deviceSettings = {
        my.services.syncthing.devices.lavos = {
            id = "KSLCF4V-WNXVWF7-5MFHBJC-QUQ43A2-JNNRT63-NW4NEMY-WFCGUVD-OCUOAQL";
            connectOverTailscale = true;
            tailscaleHostName = "lavos";
        };
    };
in {
    flake.modules.nixos.syncthing-lavos = deviceSettings;
    flake.modules.homeManager.syncthing-lavos = deviceSettings;
    flake.modules.homeManager.lavos = {...}: {
        imports = with self.modules.homeManager; [syncthing syncthing-orion];
        config.my = {
            # TODO: needs rework
            services.syncthing.folders = let
                share = ["orion"];
            in {
                secure = {
                    id = "26bfd-pbgoj";
                    devices = share;
                };
                classes = {
                    id = "9j26s-pweyy";
                    devices = share;
                };
                proj = {
                    id = "jwvcx-y7w2m";
                    devices = share;
                };
                wallpapers = {
                    id = "vjhql-ghx7b";
                    devices = share;
                };
                docs = {
                    id = "pysjc-vrzgj";
                    devices = share;
                };
            };
        };
    };
}
