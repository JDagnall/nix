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
    # ./hardware-configuration.nix
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

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    #useXkbConfig = true; # use xkb.options in tty.
  };

  system.stateVersion = "25.05"; # Did you read the comment?

}
