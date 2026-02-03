{
	lib,
	config,
	osConfig,
	...
}: let
	inherit (lib) mkIf mkEnableOption;
in {
	options = {
		ui.hyprlock.enable =
			mkEnableOption {
				description = "Enable hyprlock config";
			};
	};
	config =
		mkIf config.ui.hyprlock.enable {
			assertions = [
				{
					assertion = config.window-manager.hyprland.enable;
					message = ''
						Hyprlock cannot work without hyprland enabled.
						Please enable hyprland or disable hyprlock'';
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
									enabled = true;
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

			stylix.targets.hyprlock =
				mkIf config.stylix.enableHomeConfig {
					enable = true;
					useWallpaper = config.stylix.image != null;
				};
		};
}
