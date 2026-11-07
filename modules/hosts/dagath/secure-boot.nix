{
    lib,
    inputs,
    ...
}: {
    flake.modules.nixos.dagath = {
        imports = [
            inputs.lanzaboote.nixosModules.lanzaboote
        ];
        config = {
            boot = {
                # lanzaboote it the boot loader
                loader.systemd-boot.enable = lib.mkForce false;
                loader.grub.enable = lib.mkForce false;
                lanzaboote = {
                    enable = true;
                    # sortKey = "lanza";
                    # logLevel = "info";
                    # privateKeyFile = ;
                    # pulbicKeyFile = ;
                    pkiBundle = "/var/lib/sbctl";
                    allowUnsigned = true;
                    settings = {};
                    measuredBoot = {};
                    autoEnrollKeys = {
                        includeMicrosoftKeys = true; # ?
                    };
                };
            };
        };
    };
}
