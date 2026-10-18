{self, ...}: let
    deviceSettings = {
        my.services.syncthing.devices.pc = {
            id = "LUNWAUX-SIKFQ5O-PDYIJW7-3DCCK2A-ZAGF4M2-MR2XTCL-UNNA2O4-CEZLDQX";
            connectOverTailscale = true;
            tailscaleHostName = "pc";
        };
    };
in {
    flake.modules.nixos.syncthing-pc = deviceSettings;
    flake.modules.home.syncthing-pc = deviceSettings;
    flake.modules.home.pc = {...}: {
        imports = with self.modules.home; [syncthing syncthing-orion];
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
