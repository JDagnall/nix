{ config,
# lib,
pkgs, ... }:

{
  # config ------------------------------
  display-manager.ly.enable = true;
  window-manager.hyprland.enable = true;
  boot-loader.grub.enable = true;
  fonts.enable = true;
  # config ------------------------------

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../james.nix
    ../../modules
  ];

  environment.systemPackages = with pkgs; [ home-manager ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.networkmanager.enable = true;
  networking.hostName = "framework";
  services.openssh.enable = true;

  # adds list of currently used system packages to /etc/nixos/current-system-packages
  environment.etc."current-system-packages".text = let
    packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
    sortedUnique =
      builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
    formatted = builtins.concatStringsSep "\n" sortedUnique;
  in formatted;

  time.timeZone = "Australia/Brisbane";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    #useXkbConfig = true; # use xkb.options in tty.
  };

  # use latest linux kernal
  boot.kernelPackages = pkgs.linuxPackages_latest;
  system.stateVersion = "25.05"; # Did you read the comment?

}
