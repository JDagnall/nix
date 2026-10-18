{lib, ...}: {
    flake.modules.nixos.pc = {
        pkgs,
        config,
        modulesPath,
        ...
    }: {
        imports = [
            (modulesPath + "/installer/scan/not-detected.nix")
        ];
        config = {
            # for encrypted partition, though it is not mounted automatically
            services.lvm.enable = true;
            environment.systemPackages = with pkgs; [cryptsetup];

            boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
            boot.initrd.kernelModules = [];
            boot.kernelModules = ["kvm-amd"];
            boot.extraModulePackages = [];

            # TODO: needs to go to disko
            # 1TB SSD NVME
            fileSystems."/" = {
                device = "/dev/disk/by-label/NIXROOT";
                fsType = "ext4";
            };

            fileSystems."/boot" = {
                device = "/dev/disk/by-label/NIXBOOT";
                fsType = "vfat";
                options = ["fmask=0077" "dmask=0077"];
            };
            # needed for ntfs filesystems
            boot.supportedFilesystems = ["ntfs"];
            # 2TB HDD SATA
            fileSystems."/games" = {
                device = "/dev/disk/by-label/LINUX_GAMES";
                fsType = "ntfs-3g";
                options = [
                    "users" # any user can mount the drive
                    "nofail" # dont crash if can't mount
                    "exec" # permit to excecute binaries
                    "rw"
                    "permissions" # POSIX permissions
                    "uid=${
                        if config.users.users ? james && lib.isStringLike config.users.users.james.uid
                        then lib.toString config.users.users.james.uid
                        else "1000"
                    }"
                    "gid=${
                        if config.users.groups ? james && lib.isStringLike config.users.groups.james.gid
                        then lib.toString config.users.groups.james.gid
                        else "998"
                    }"
                    "umask=0033"
                    "fmask=0033"
                    "dmask=0033"
                ];
            };

            swapDevices = [
                {
                    device = "/var/lib/swapFile";
                    size = 32 * 1024;
                }
            ];

            networking.useDHCP = lib.mkDefault true;
            # networking.interfaces.enp42s0.useDHCP = lib.mkDefault true;
            # networking.interfaces.wlp34s0.useDHCP = lib.mkDefault true;

            nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
            hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        };
    };
}
