{ pkgs, lib, config, ... }:
let inherit (lib) mkIf mkEnableOption;
in {
  options = {
    window-manager.hyprland.enable = mkEnableOption {
      default = false;
      description = "enable hyprland window-manager";
    };
  };
  config = mkIf config.window-manager.hyprland.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      # withUWSM = true; # with session manager
    };

    # programs.hyprlock.enable = true; # hyprland lock daemon
    # services.hypridle.enable = true; # hyprland idle daemon

    environment.sessionVariables = {
      # if invisible cursor
      WLR_NO_HARDWARE_CURSORS = "1";
      # hint electron apps to use wayland
      NIXOS_OZONE_WL = "1";
    };

    # environment.systemPackages = with pkgs; [
    #     # kitty # needed for hyprland default config
    #     # wezterm
    # ];

    hardware = {
      # Opengl
      graphics.enable = true;

      # Most wayland compositors need this
      nvidia.modesetting.enable = true;
    };

    # waybar
    # (pkgs.waybar.overrideAttrs (oldAttrs: {
    #    mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    #  })
    # )

    # XDG portal
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
