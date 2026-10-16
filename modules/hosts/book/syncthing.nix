{self, ...}: let
    deviceSettings = {
        my.services.syncthing.devices.book = {
            id = "AGENCX4-T4DBKCJ-U4VUN6S-ZE2RBSI-ECBMERW-3OOL5MP-4AEIWFH-GAAN5AV";
            connectOverTailscale = false;
        };
    };
in {
    flake.modules.nixos.syncthing.book = deviceSettings;
    flake.modules.home.syncthing.book = deviceSettings;
    flake.modules.home.book = {...}: {
        imports = with self.modules.home; [syncthing syncthing.orion];
        config.my = {
            # TODO: needs rework
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
