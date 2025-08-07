{ lib, config, ... }: {
  options = {
    boot-loader.systemd-boot.enable = lib.mkEnableOption {
      default = false;
      description = "Enable systemd boot loader";
    };
  };
  config = lib.mkIf config.boot-loader.systemd-boot.enable {
    boot.loader.systemd-boot = {
      enable = true;
    };
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
