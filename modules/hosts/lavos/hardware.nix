{
    # self,
    lib,
    inputs,
    ...
}: {
    flake.modules.nixos.lavos = {
        config,
        # pkgs,
        modulesPath,
        ...
    }: {
        imports = [
            (modulesPath + "/installer/scan/not-detected.nix")
            inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
        ];
        config = {
            boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod"];
            boot.initrd.kernelModules = [];
            boot.kernelModules = ["kvm-amd"];
            boot.extraModulePackages = [];
            # boot.kernelParams = [
            # 	"xhci_hcd.power_save=0"
            # ];

            # TODO: should be disko at some point
            fileSystems."/" = {
                device = "/dev/disk/by-uuid/292fb08e-ba01-4bcc-a28e-3e2a03d1002a";
                fsType = "ext4";
            };

            fileSystems."/boot" = {
                device = "/dev/disk/by-uuid/5482-1199";
                fsType = "vfat";
                options = ["fmask=0077" "dmask=0077"];
            };

            swapDevices = [
                {device = "/dev/disk/by-uuid/c43456fb-479a-44ec-9134-edeba3f1929c";}
            ];

            # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
            # (the default) this is the recommended approach. When using systemd-networkd it's
            # still possible to use this option, but it's recommended to use it in conjunction
            # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
            networking.useDHCP = lib.mkDefault true;
            # networking.interfaces.wlp192s0.useDHCP = lib.mkDefault true;

            nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
            hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

            # updates framework drivers, run fwupdmgr update
            services.fwupd.enable = true;
        };
    };
}
