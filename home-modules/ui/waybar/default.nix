{
	lib,
	config,
	...
}: let
	inherit
		(lib)
		mkIf
		mkEnableOption
		mkOption
		types
		optionalAttrs
		;
in {
	options = {
		ui.waybar.enable =
			mkEnableOption {
				default = false;
				description = "Enable waybar config";
			};
		ui.waybar.autostart =
			mkOption {
				type = types.bool;
				default = config.ui.waybar.enable;
				description = ''
					Enable autostart for waybar. Configured in 
					whichever enabled config should be responsible for autostarts.'';
			};
	};
	config =
		mkIf config.ui.waybar.enable {
			assertions = [
				{
					assertion = config.window-manager.hyprland.enable;
					message = ''
						Waybar cannot work without hyprland, 
						please enable hyprland or disable waybar.'';
				}
			];
			programs.waybar = {
				enable = true;
				settings = [
					{
						modules-left = [
							"hyprland/workspaces"
							"cpu"
							"memory"
						];
						modules-center = ["clock"];
						modules-right = [
							"group/expand"
							"battery"
							"network"
							"bluetooth"
							"pulseaudio"
							# "pulseaudio/slider"
							"idle_inhibitor"
							"custom/power"
						];
						"hyprland/workspaces" = {
							format = "{icon}";
							format-icons = {
								active = "";
								default = "";
								empty = "";
							};
							persistent-workspaces = {
								"*" = [
									1
									2
									3
									4
									5
								];
							};
						};
						network = {
							format-wifi = "{essid} 󰖩 ";
							format-ethernet = "{ifname} 󰈀 ";
							format-disconnected = " ";
							tooltip-format = "";
							tooltip-format-wifi = "{ipaddr}";
							tooltip-format-ethernet = "{ipaddr}";
							min-length = 2;
							max-length = 10;
						};
						battery = {
							states = {
								good = 95;
								warning = 30;
								critical = 20;
							};
							interval = 15;
							format-time = "{H}:{M}";
							format = "{capacity}% {icon}";
							min-length = 2;
							justify = "center";
							format-charging = "{capacity}% {icon}";
							format-icons = {
								default = [
									"󰁺"
									"󰁻"
									"󰁼"
									"󰁽"
									"󰁾"
									"󰁿"
									"󰂀"
									"󰂁"
									"󰂂"
									"󰁹"
								];
								charging = [
									"󰢜"
									"󰂆"
									"󰂇"
									"󰂈"
									"󰢝"
									"󰂉"
									"󰢞"
									"󰂊"
									"󰂋"
									"󰂅"
								];
							};
							tooltip-format = "{time}";
						};
						bluetooth =
							{
								format = "󰂲 "; # default no connection or off
								format-connected = "󰂯 {device_alias}";
								min-length = 2;
								max-length = 10;
								tooltip-format-connected = "{device_enumerate}";
								tooltip-format = ""; # when there are no connected devices
								tooltip-format-enumerate-connected = "{device_alias}";
							}
							// optionalAttrs config.ui.bt-applet.enable {on-click = "blueman-manager";};
						pulseaudio =
							{
								format = "{volume}% {icon}";
								format-bluetooth = "{volume}% {icon}";
								min-length = 2;
								justify = "center";
								format-muted = "󰖁 ";
								format-icons = [
									"󰕿 "
									"󰖀 "
									"󰕾 "
								];
								tooltip = false;
								states = {
									high = 85;
									medium = 50;
									low = 1;
									off = 0;
								};
							}
							// optionalAttrs config.ui.pavucontrol.enable {on-click = "pavucontrol";};
						"pulseaudio/slider" = {
							orientation = "horizontal";
						};
						clock = {
							format = " {:%I:%M %p %a %b %d}";
							tooltip = false;
						};
						tray = {
							icon-size = 17;
							spacing = 10;
							tooltip = false;
						};
						cpu = {
							format = " {usage}%";
							tooltip = false;
							min-length = 6;
							max-length = 6;
							interval = 30;
						};
						memory = {
							format = " {used}Gb";
							states = {
								warning = 75;
								critical = 90;
							};
							tooltip = false;
							min-length = 9;
							max-length = 9;
							interval = 30;
						};
						"idle_inhibitor" = {
							format = "{icon}";
							format-icons = {
								activated = "󰒳 ";
								deactivated = "󰒲 ";
							};
						};
						"custom/power" = {
							format = "󰐥 ";
							tooltip = false;
							menu = "on-click";
							menu-file = "${builtins.toString ./power_menu.xml}";
							menu-actions = {
								lock = "loginctl lock-session";
								# this is hyprland specific but this config asserts that this is hyprland anyway
								logout = "hyprctl dispatch exit";
								shutdown = "shutdown now";
								reboot = "reboot";
								sleep = "systemclt hibernate";
							};
						};
						# tray drawer
						"group/expand" = {
							orientation = "horizontal";
							drawer = {
								transition-duration = 500;
								transition-to-left = true;
								click-to-reveal = true;
							};
							modules = [
								"custom/expand"
								"tray"
								"custom/endpoint"
							];
						};
						"custom/expand" = {
							format = "󰅁";
							tooltip = false;
						};
						"custom/endpoint" = {
							format = "|";
							tooltip = false;
						};
						expand-center = false;
						expand-left = false;
						expand-right = false;
						layer = "bottom";
						output = null; # for multiple monitors
						position = "top";
						width = null;
						height = null;
						no-center = false;
						spacing = 5;
						mode = "dock";
						start_hidden = false;
						reload_style_on_change = true;
						fixed_center = true;
					}
				];
				style = builtins.readFile ./style.css;
				## DEBUG
				systemd.enableDebug = false; # debug logging
				systemd.enableInspect = false; # mouse over for CSS classes
			};
			# stylix theming
			stylix.targets.waybar =
				mkIf config.stylix.enableHomeConfig {
					enable = true; # just adds colors and font config
					addCss = false;
					enableCenterBackColors = true;
					enableRightBackColors = true;
					enableLeftBackColors = true;
					font = "serif";
				};
		};
}
