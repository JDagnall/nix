{
	pkgs,
	lib,
	config,
	...
}: let
	inherit (lib) mkOption optionals types;
in {
	imports = [
		./rofi.nix
		./waybar
		./swww.nix
		./firefox.nix
		./hyprpaper.nix
		./hyprlock.nix
		./hypridle.nix
		./syncthingtray.nix
		./mako.nix
		./swayosd.nix
		./applets.nix
		./vscode.nix
		./obsidian.nix
		./thunar.nix
		./imv.nix
		./hypr-screenshot.nix
		./easyeffects.nix
		./brave.nix
		./noctalia.nix
		./libresuite.nix
	];
	# ui packages that only need to be installed
	options = {
		ui.nwg-look.enable =
			mkOption {
				default = false;
				type = types.bool;
				description = "Install nwg-look";
			};
		ui.spotify.enable =
			mkOption {
				default = false;
				type = types.bool;
				description = "Install spotify";
			};
		ui.legcord.enable =
			mkOption {
				default = false;
				type = types.bool;
				description = "Install legcord";
			};
		ui.slack.enable =
			mkOption {
				default = false;
				type = types.bool;
				description = "Install slack";
			};
		ui.pavucontrol.enable =
			mkOption {
				default = false;
				type = types.bool;
				description = "Install pavucontrol";
			};
		ui.drawio.enable =
			mkOption {
				default = false;
				type = types.bool;
				description = "Install draw.io";
			};
		ui.vlc.enable =
			mkOption {
				default = false;
				type = types.bool;
				description = "Install vlc";
			};
		ui.qbittorrent.enable = lib.mkEnableOption "Install qbittorrent";
		ui.seahorse.enable = lib.mkEnableOption "Install seahorse";
		ui.freetube.enable = lib.mkEnableOption "Install freetube";
	};
	config = let
		inherit
			(config.ui)
			nwg-look
			spotify
			legcord
			slack
			pavucontrol
			drawio
			vlc
			qbittorrent
			seahorse
			freetube
			;
	in {
		home.packages =
			[]
			++ optionals nwg-look.enable [pkgs.nwg-look]
			++ optionals spotify.enable [pkgs.spotify]
			++ optionals legcord.enable [pkgs.legcord]
			++ optionals slack.enable [pkgs.slack]
			++ optionals pavucontrol.enable [pkgs.pavucontrol]
			++ optionals drawio.enable [pkgs.drawio]
			++ optionals vlc.enable [pkgs.vlc]
			++ optionals qbittorrent.enable [pkgs.qbittorrent]
			++ optionals seahorse.enable [pkgs.seahorse]
			++ optionals freetube.enable [pkgs.freetube];
	};
}
