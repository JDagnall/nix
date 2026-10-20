{self, ...}: let
    deviceSettings = {
        my.services.syncthing.devices.dante = {
            id = "AGENCX4-T4DBKCJ-U4VUN6S-ZE2RBSI-ECBMERW-3OOL5MP-4AEIWFH-GAAN5AV";
            connectOverTailscale = false;
        };
    };
in {
    flake.modules.nixos.syncthing-dante = deviceSettings;
    flake.modules.homeManager.syncthing-dante = deviceSettings;
    flake.modules.homeManager.dante = {...}: {
        imports = with self.modules.homeManager; [syncthing syncthing-orion];
        config.my = {
            services.syncthing.folders = let
                share = ["orion"];
            in {
                secure = {
                    id = "26bfd-pbgoj";
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
