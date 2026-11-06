{self, ...}: let
    deviceSettings = {
        my.services.syncthing.devices.dagath = {
            id = "CG7CQYZ-24MKTKR-Z3IHSVD-W3RUC34-C3DHO7L-HP2RC7Y-6QTDXQY-E5FZMQI";
            connectOverTailscale = false;
        };
    };
in {
    flake.modules.nixos.syncthing-dagath = deviceSettings;
    flake.modules.homeManager.syncthing-dagath = deviceSettings;
    flake.modules.homeManager.dagath-james = {...}: {
        imports = with self.modules.homeManager; [syncthing syncthing-orion];
        config.my = {
            services.syncthing.folders = let
                share = ["orion"];
            in {
                secure = {
                    id = "26bfd-pbgoj";
                    devices = share;
                };
            };
        };
    };
}
