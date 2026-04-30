{
	pkgs,
	lib,
	config,
	...
}: let
	inherit (lib) optionals mkOption types;
in {
	imports = [
		./git.nix
		./keepassxc.nix
		./gh-cli.nix
		./nh.nix
		./nix-index.nix
	];
	# tools which just need to be enabled with no other config
	options = {
		tools.basic.enable =
			mkOption {
				default = true;
				type = types.bool;
				description = "Enable a small list of very basic tools. Always want this on.";
			};
		tools.mycli.enable =
			mkOption {
				default = false;
				description = "Enable mycli";
			};
		tools.fd.enable =
			mkOption {
				default = true;
				type = types.bool;
				description = "Enable fd";
			};
		tools.ripgrep.enable =
			mkOption {
				default = true;
				type = types.bool;
				description = "Enable ripgrep";
			};
		tools.cloc.enable =
			mkOption {
				default = true;
				type = types.bool;
				description = "Enable cloc";
			};
		tools.gzip.enable =
			mkOption {
				default = true;
				type = types.bool;
				description = "Enable gzip";
			};
		tools.zip.enable =
			mkOption {
				default = true;
				type = types.bool;
				description = "Enable zip and unzip";
			};
		tools.btop.enable =
			mkOption {
				default = true;
				type = types.bool;
				description = "Enable btop";
			};
		tools.brightnessctl.enable =
			mkOption {
				default = true;
				type = types.bool;
				description = "Enable brightnessctl. A screen brightness cli utility.";
			};
		tools.ncat.enable =
			mkOption {
				default = true;
				type = types.bool;
				description = "Enable netcat.";
			};
		tools.nmap.enable =
			mkOption {
				default = true;
				type = types.bool;
				description = "Enable nmap.";
			};
		tools.playerctl.enable =
			mkOption {
				default = true;
				type = types.bool;
				description = "Enable playerctl. For pause play keys.";
			};
		tools.hwinfo.enable =
			mkOption {
				default = true;
				type = types.bool;
				description = "Enable hwinfo.";
			};
		tools.usbutils.enable =
			mkOption {
				default = true;
				type = types.bool;
				description = "Enable usbutils.";
			};
		tools.lshw.enable =
			mkOption {
				default = true;
				type = types.bool;
				description = "Enable lshw.";
			};
		tools.tshark.enable =
			mkOption {
				default = true;
				type = types.bool;
				description = "Enable tshark.";
			};
		tools.snakeviz.enable =
			mkOption {
				default = false;
				type = types.bool;
				description = "Enable snakeviz. A python application for viewing cProfile  .prof files.";
			};
		tools.ngrok.enable =
			mkOption {
				default = false;
				type = types.bool;
				description = "Enable ngrok. A reverse tcp tunneling agent, for opening ports.";
			};
		tools.rlwrap.enable =
			mkOption {
				default = true;
				type = types.bool;
				description = "Enable rlwrap. A readline wrapper for cmdline utilities. Use with ssh for high latency connections.";
			};
		tools.android-tools.enable = lib.mkEnableOption "Enable android-tools, utilities for android development including adb";
	};
	config = let
		inherit
			(config.tools)
			basic
			mycli
			fd
			ripgrep
			cloc
			gzip
			btop
			brightnessctl
			ncat
			nmap
			playerctl
			lshw
			usbutils
			hwinfo
			tshark
			snakeviz
			ngrok
			rlwrap
			android-tools
			;
		basicList = with pkgs; [
			util-linux
			net-tools
			zip
			unzip
			file
			tree
		];
	in {
		home.packages =
			[
				pkgs.zip
			]
			++ optionals basic.enable basicList
			++ optionals mycli.enable [pkgs.mycli]
			++ optionals fd.enable [pkgs.fd]
			++ optionals ripgrep.enable [pkgs.ripgrep]
			++ optionals cloc.enable [pkgs.cloc]
			++ optionals gzip.enable [pkgs.gzip]
			++ optionals btop.enable [pkgs.btop]
			++ optionals brightnessctl.enable [pkgs.brightnessctl]
			++ optionals ncat.enable [pkgs.netcat]
			++ optionals nmap.enable [pkgs.nmap]
			++ optionals playerctl.enable [pkgs.playerctl]
			++ optionals lshw.enable [pkgs.lshw]
			++ optionals hwinfo.enable [pkgs.hwinfo]
			++ optionals usbutils.enable [pkgs.usbutils]
			++ optionals tshark.enable [pkgs.tshark]
			++ optionals snakeviz.enable [pkgs.python312Packages.snakeviz]
			++ optionals ngrok.enable [pkgs.ngrok]
			++ optionals rlwrap.enable [pkgs.rlwrap]
			++ optionals android-tools.enable [pkgs.android-tools];
	};
}
