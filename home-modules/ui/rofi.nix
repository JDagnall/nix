{
	pkgs,
	lib,
	config,
	...
}: let
	inherit
		(lib)
		mkIf
		mkEnableOption
		mkOption
		;
in {
	options = {
		ui.rofi.enable =
			mkEnableOption {
				default = false;
				description = "Enable rofi config";
			};
		ui.rofi.stylixOverride =
			mkOption {
				default = true;
				description = ''
					Stylix makes a bad colour choice for rofi with catppuccin,
					so I override it with another one of the base16 colours.'';
			};
	};
	config =
		mkIf config.ui.rofi.enable {
			programs.rofi = {
				enable = true;
				cycle = true; # cycle through results
				extraConfig = {
					show-icons = true;
					terminal = "wezterm";
					drun-display-format = "{icon} {name}";
					location = 0;
					disable-history = false;
					hide-scrollbar = true;
					display-drun = " 󰀻  Apps ";
					display-run = "   Run ";
					display-window = " 󰕰  Window";
					display-ssh = "   SSH";
					sidebar-mode = true;
					fixed-num-lines = true; # number of lines in picker is always the same
					kb-secondary-copy = ""; # was previously <C-c>
					kb-cancel = "Control+c,Escape"; # exit rofi with <C-c>
					matching = "fuzzy"; # fuzzy search
					sort = true; # sorts in order of fuzzy match
					sorting-method = "fzf";
				};
				location = "center";
				modes = [
					"drun"
					"window"
					"ssh"
				];
				# terminal =  # path to terminal to be used to run terminal cmds

				# layout stuff, stylix does colours
				theme = let
					inherit (config.lib.formats.rasi) mkLiteral;
					inherit (config.lib.stylix) colors;
					inherit (config.stylix) opacity;
					# using the method used in the stylix rofi config to change
					# base16 colors into rgba literals.
					mkRgba = opacityString: color: let
						c = colors;
						r = c."${color}-rgb-r";
						g = c."${color}-rgb-g";
						b = c."${color}-rgb-b";
					in
						mkLiteral "rgba ( ${r}, ${g}, ${b}, ${opacityString} % )";
					rofiOpacity = toString (builtins.ceil (opacity.popups * 100));
					purple = mkRgba rofiOpacity "base0E"; # in most colour schemes
				in
					{
						window.height = mkLiteral "40%";
						window.width = mkLiteral "40%";
						listview = {
							columns = 1;
							lines = 10;
						};
						element.padding = mkLiteral "10px";
					}
					// (
						if config.ui.rofi.stylixOverride
						then {
							"element selected.normal".background-color = lib.mkForce purple;
							"button selected".background-color = lib.mkForce purple;
						}
						else {}
					);

				# xoffset = ;
				# yoffset = ;
			};
			stylix.targets.rofi.enable = config.stylix.enableHomeConfig;
		};
}
