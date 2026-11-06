{
    lib,
    inputs,
    ...
}: {
    flake.modules.nixos.dagath = {config, ...}: {
        imports = [inputs.disko.nixosModules.disko];

        config = {
            boot.initrd.availableKernelModules = [];

            boot.initrd.kernelModules = [];
            boot.kernelModules = [];
            boot.extraModulePackages = [];
            boot.blacklistedKernelModules = [];
            boot.kernelParams = [];

            disko.devices = {
                disk = {
                    ssd = {
                        device = "";
                        type = "disk";
                        content = {
                            type = "gpt";
                            partitions = {
                                NIXBOOT = {
                                    type = "EF00";
                                    size = "500M";
                                    content = {
                                        type = "filesystem";
                                        format = "vfat";
                                        mountpoint = "/boot";
                                        mountOptions = ["umask=0077" "fmask=0077"];
                                    };
                                };
                                NIXROOT = {
                                    size = "100%";
                                    content = {
                                        type = "filesystem";
                                        format = "ext4";
                                        mountpoint = "/";
                                    };
                                };
                                swap = {
                                    size = "2G";
                                    content = {
                                        type = "swap";
                                        discardPolicy = "both";
                                        resumeDevice = true;
                                    };
                                };
                            };
                        };
                    };
                };
            };

            # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
            # (the default) this is the recommended approach. When using systemd-networkd it's
            # still possible to use this option, but it's recommended to use it in conjunction
            # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
            networking.useDHCP = lib.mkDefault true;
            # networking.interfaces.enp1s0f0.useDHCP = lib.mkDefault true;

            nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
            hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        };
    };
}
