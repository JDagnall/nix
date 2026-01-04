{
	lib,
	config,
	osConfig,
	...
}: let
	inherit
		(lib)
		mkIf
		mkEnableOption
		mkOption
		mkOrder
		mkMerge
		;
in {
	options = {
		window-manager.hyprland.enable =
			mkEnableOption {
				default = false;
				description = "Enable Hyprland config";
			};
		window-manager.hyprland.monitors =
			mkOption {
				default = [", preferred, auto, 1"];
				type = lib.types.listOf lib.types.str;
				description = ''
					The device specific monitor config to be added to the hyprland config.
					                 Generally just defines the monitors and thier positions'';
			};
	};
	config =
		mkIf config.window-manager.hyprland.enable {
			wayland.windowManager.hyprland = {
				enable = true;
				systemd = let
					inherit (osConfig.programs.hyprland) withUWSM;
				in {
					# cannot be enabled if UWSM is enabled in nixos
					enable = !withUWSM;
					# extraCommands = [];
					# enableXdgAutostart = true;
					# variables = [];
				};
				# importantPrefixes = [];
				# portalPackage = ;
				xwayland.enable = true;
				# plugins = [ ];
				sourceFirst = true;
				settings = let
					inherit (lib) optionals;
					inherit (config.ui) swayosd;
					inherit (osConfig.services) pipewire;
					inherit
						(config.tools)
						brightnessctl
						playerctl
						;
				in {
					"$mod" = "SUPER";
					bindel =
						[]
						++ (
							if (swayosd.enable && brightnessctl.enable)
							then [
								",XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
								",XF86MonBrightnessUp, exec, swayosd-client --brightness raise"
							]
							else []
						)
						++ (
							if (brightnessctl.enable && !swayosd.enable)
							then [
								",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
								",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
							]
							else []
						)
						++ (
							if (swayosd.enable && pipewire.enable)
							then [
								",XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
								",XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
								",XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
								",XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
							]
							else []
						)
						++ (
							if (pipewire.enable && !swayosd.enable)
							then [
								",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
								",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
								",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
								",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
							]
							else []
						);

					bindl =
						[]
						++ (
							if playerctl.enable
							then [
								",XF86AudioNext, exec, playerctl next"
								",XF86AudioPause, exec, playerctl play-pause"
								",XF86AudioPlay, exec, playerctl play-pause"
								",XF86AudioPrev, exec, playerctl previous"
							]
							else []
						);
					bind = [] ++ optionals config.tools.keepmenu.enable ["$mod, a, exec, keepmenu"];
					monitor = config.window-manager.hyprland.monitors;
				};
				extraConfig = let
					configFile = builtins.readFile ./hyprland.conf;
					autostarts = ''
						#################
						### AUTOSTART ###
						#################
						${
							if config.ui.waybar.autostart
							then "exec-once = pidof waybar || waybar &"
							else ""
						}
						${
							if config.ui.syncthingtray.autostart
							then "exec-once = syncthingtray --wait &"
							else ""
						}
						${
							if config.tools.keepassxc.autostart
							then "exec-once = keepassxc --minimized &"
							else ""
						}
					'';
					variables = ''
						#################
						### VARIABLES ###
						#################
						# $mod = SUPER # sets "Windows" key as the main mod key
						# there is no alternative for either of these at the moment so they have to be set
						${
							if config.ui.rofi.enable
							then "$menu = rofi -show drun"
							else "$menu = rofi -show drun"
						}
						${
							if config.term.wezterm.enable
							then "$terminal = wezterm"
							else "$terminal = wezterm"
						}
					'';
					orderedConfigFile = mkOrder 500 configFile;
					orderedVariables = mkOrder 250 variables;
					orderedAutostarts = mkOrder 1000 autostarts;
					merged =
						mkMerge [
							orderedVariables
							orderedConfigFile
							orderedAutostarts
						];
				in
					merged;
			};
			stylix.targets.hyprland =
				mkIf config.stylix.enableHomeConfig {
					enable = true;
					hyprpaper.enable = config.ui.hyprpaper.enable;
				};
		};
}
