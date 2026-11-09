{
    lib,
    inputs,
    ...
}: {
    flake.modules.nixos.dagath = {config, ...}: {
        imports = [
            inputs.disko.nixosModules.disko
            inputs.nixos-hardware.nixosModules.microsoft-surface-common
        ];

        config = {
            boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "sd_mod"];
            # boot.initrd.kernelModules = [];
            # KVM for intel, proprietary wifi firmware and touchscreen modules
            boot.kernelModules = ["kvm_intel" "mwifiex_pcie" "hid_multitouch" "i2c_hid_acpi"];
            # boot.kernelModules = ["kvm_intel"];
            # boot.extraModulePackages = [];
            # boot.blacklistedKernelModules = [];
            # boot.kernelParams = [];

            # this determines the kernel version that is loaded with
            # the microsoft surface patches, there is "stable" and "longterm"
            # As of writing, "longterm" is 6.18 and "stable" is 7.3
            hardware.microsoft-surface.kernelVersion = "stable";

            disko.devices = {
                disk = {
                    ssd = {
                        device = "/dev/disk/by-id/nvme-KBG40ZNS128G_TOSHIBA_MEMORY_Y9SPD25IP6JL";
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
            hardware.enableRedistributableFirmware = true; # need this for surface kernel drivers.
            hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        };
    };
}
