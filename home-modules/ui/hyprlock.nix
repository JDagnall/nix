{
	lib,
	config,
	osConfig,
	...
}: let
	inherit (lib) types mkIf mkEnableOption mkOption;
in {
	options = {
		ui.hyprlock.enable =
			mkEnableOption {
				description = "Enable hyprlock config";
			};
		ui.hypridle.enable =
			mkEnableOption {
				description = "Enable hypridle config";
			};
		ui.hypridle.profile =
			mkOption {
				description = "The profile for the idle timeouts etc, currently one for a desktop and one for a laptop";
				type = types.enum ["laptop" "desktop"];
				default = "laptop";
			};
	};
	config =
		mkIf (config.ui.hypridle.enable || config.ui.hyprlock.enable) {
			assertions = [
				{
					assertion = config.window-manager.hyprland.enable;
					message = ''
						hyprlock and hypridle cannot work without hyprland enabled.
						Please enable hyprland or disable hyprlock'';
				}
				{
					assertion = (config.ui.hypridle.enable && config.ui.hyprlock.enable) || config.ui.hyprlock.enable;
					message = ''
						hypridle cannot work without hyprlock enabled.
						Please enable hyprlock or disable hypridle'';
				}
				{
					assertion =
						(config.ui.hypridle.enable && config.tools.brightnessctl.enable) || !config.ui.hypridle.enable;
					message = ''
						hypridle cannot work without brightnessctl. Pleas enable brightnessctl
						or disable hypridle'';
				}
			];
			programs.hyprlock =
				mkIf config.ui.hyprlock.enable {
					enable = true;
					settings = {
						general = {
							hide_cursor = true;
							ignore_empty_input = false;
							immediate_render = true;
							text_trim = true;
						};
						auth = {
							pam = {
								enabled = true;
								# module = ;
							};
							# if fingerprint daemon is enabled
							fingerprint =
								mkIf osConfig.services.fprintd.enable {
									enabled = true; # currently
									ready_message = "Scan fingerprint to unlock";
									present_message = "Scanning fingerprint";
									retry_delay = 250; # ms
								};
						};
						animations = {
							enabled = true;
						};
					};
				};

			# hypridle execs commands after set timeouts of inacrivity,
			# it also can exec commands when `loginctl lock/unlock` commands are issued
			services.hypridle = let
				laptop_profile = [
					# dim screen after a period of inactivity
					{
						timeout = 180; # sec
						# set brightness low
						on-timeout = "brightnessctl -s set 10";
						# set brightness back
						on-resume = "brightnessctl -r";
					}
					# do same for keyboard backlight
					{
						timeout = 180; # sec
						on-timeout = "brightnessctl -sd rgb:kbd_backlight set 0";
						# set brightness back
						on-resume = "brightnessctl -rd rgb:kbd_backlight";
					}
					# fully turns the screen off
					{
						timeout = 300; # sec
						on-timeout = "hyprctl dispatch dpms off";
						# change brightness back,
						on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
					}
					# lock session
					{
						timeout = 900; # 15 min
						on-timeout = "loginctl lock-session";
					}
					# suspend
					{
						timeout = 960; # 16 min
						on-timeout = "systemctl suspend";
					}
				];
				desktop_profile = [
					# fully turns the screen off
					{
						timeout = 300; # sec
						on-timeout = "hyprctl dispatch dpms off";
						# change brightness back,
						on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
					}
					# lock session
					{
						timeout = 900; # 15 min
						on-timeout = "loginctl lock-session";
					}
					# suspend after 30 mins
					{
						timeout = 1800; # sec
						on-timeout = "systemctl hibernate";
					}
				];
				inherit (config.ui.hypridle) profile;
			in
				mkIf config.ui.hypridle.enable {
					enable = true;
					settings = {
						general = {
							# avoid starting multiple hyprlock instances.
							lock_cmd = "pidof hyprlock || hyprlock";
							# on_lock_cmd = ""; # when the session is locked at all
							# on_unlock_cmd = ""; # when the session is unlocked at all

							# lock before suspend.
							before_sleep_cmd = "loginctl lock-session";
							# to avoid having to press a key twice to turn on the display.
							after_sleep_cmd = "hyprctl dispatch dpms on";

							ignore_dbus_inhibit = false;
							ignore_systemd_inhibit = false;
							ignore_wayland_inhibit = false;
							inhibit_sleep = 2; # normal
						};
						listener =
							if profile == "desktop"
							then desktop_profile
							else laptop_profile;
					};
				};

			stylix.targets.hyprlock =
				mkIf (config.ui.hyprlock.enable && config.stylix.enableHomeConfig) {
					enable = true;
					useWallpaper = config.stylix.image != null;
				};
		};
}
