{
	pkgs,
	lib,
	config,
	...
}: let
	inherit (lib) mkIf mkEnableOption;
in {
	options = {
		window-manager.hyprland.enable =
			mkEnableOption {
				default = false;
				description = "enable hyprland window-manager";
			};
	};
	config =
		mkIf config.window-manager.hyprland.enable {
			programs.hyprland = {
				enable = true;
				xwayland.enable = true;
				# UWSM improves systemd compatability stuff with wayland
				# make sure hyprland.systemd.enable is false, in home-manager or otherwise
				# as this will cause launching the session to crash
				withUWSM = true;
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

			hardware = {
				# Opengl
				graphics.enable = true;
			};

			# XDG portal
			xdg.portal.enable = true;
			xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
		};
}
