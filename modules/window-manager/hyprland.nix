{
    pkgs,
    lib,
    config,
    inputs,
    ...
}: let
    inherit (lib) mkIf mkEnableOption;
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
            # UWSM improves systemd compatability stuff with wayland
            # make sure hyprland.systemd.enable is false, in home-manager or otherwise
            # as this will cause launching the session to crash
            withUWSM = true;
            package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
            portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
        };
        # cachix cache for hyprland package, so it doesn't have to be
        # rebuilt since we are pulling from the development branch
        nix.settings = {
            substituters = ["https://hyprland.cachix.org"];
            trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
        };

        programs.uwsm.waylandCompositors = {
            hyprland = {
                prettyName = "Hyprland";
                comment = "Hyprland compositor managed by UWSM";
                binPath = "/run/current-system/sw/bin/Hyprland";
            };
        };

        environment.sessionVariables = {
            # if invisible cursor
            WLR_NO_HARDWARE_CURSORS = "1";
            # hint electron apps to use wayland
            NIXOS_OZONE_WL = "1";
        };

        environment.systemPackages = with pkgs; [
            wezterm # needed or could get stuck without a terminal
        ];

        hardware = let
            # this is necesary because there will be a version mismatch
            # between hyprlands input pkgs and the global config packages
            # and apparently hyprland wants exact version matches with mesa
            hyprland-pkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
        in {
            # Opengl
            graphics = {
                enable = true;
                package = hyprland-pkgs.mesa;

                # enable 32 Bit, apparently good for steam
                enable32Bit = true;
                package32 = hyprland-pkgs.pkgsi686Linux.mesa;
            };
        };

        # XDG portal
        xdg.portal.enable = true;
        xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };
}
