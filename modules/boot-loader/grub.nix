{ lib, config, ... }: {
  options = {
    config.boot-loader.grub.enable = lib.MkEnableOption {
      default = false;
      description = "Enable grub boot loader";
    };
  };
  config = lib.mkIf config.boot-loader.grub.enable {
    boot.loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOsProber = true;
      fsIdentifier = "label";
      extraEntries = ''
        menuentry "Reboot" {
            reboot
        }
        menuentry "Poweroff" {
            halt
        }
      '';

      # boot.loader.efi.canTouchEfiVariables = true;
    };
  };
}
