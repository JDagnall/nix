{
    pkgs,
    lib,
    config,
    ...
}: let
    inherit (lib) optionals mkOption types;
    tools = [
        {
            name = "mycli";
            default = false;
            pkg = pkgs.mycli;
        }
        {
            name = "fd";
            default = true;
            pkg = pkgs.fd;
            desc = "";
        }
        {
            name = "ripgrep";
            default = true;
            pkg = pkgs.ripgrep;
            desc = "";
        }
        {
            name = "cloc";
            default = true;
            pkg = pkgs.cloc;
            desc = "";
        }
        {
            name = "gzip";
            default = true;
            pkg = pkgs.gzip;
            desc = "";
        }
        {
            name = "brightnessctl";
            default = true;
            pkg = pkgs.brightnessctl;
            desc = " A screen brightness cli utility.";
        }
        {
            name = "nmap";
            default = true;
            pkg = pkgs.nmap;
            desc = "nmap + ncat.";
        }
        {
            name = "playerctl";
            default = true;
            pkg = pkgs.playerctl;
            desc = " For pause play keys.";
        }
        {
            name = "hwinfo";
            default = true;
            pkg = pkgs.hwinfo;
            desc = "";
        }
        {
            name = "usbutils";
            default = true;
            pkg = pkgs.usbutils;
            desc = "";
        }
        {
            name = "lshw";
            default = true;
            pkg = pkgs.lshw;
            desc = "";
        }
        {
            name = "tshark";
            default = true;
            pkg = pkgs.tshark;
            desc = "";
        }
        {
            name = "snakeviz";
            default = false;
            pkg = pkgs.python314Packages.snakeviz;
            desc = " A python application for viewing cProfile  .prof files.";
        }
        {
            name = "ngrok";
            default = false;
            pkg = pkgs.ngrok;
            desc = " A reverse tcp tunneling agent, for opening ports.";
        }
        {
            name = "rlwrap";
            default = true;
            pkg = pkgs.rlwrap;
            desc = " A readline wrapper for cmdline utilities. Use with ssh for high latency connections.";
        }
        {
            name = "android-tools";
            default = false;
            pkg = pkgs.android-tools;
            desc = "Enable android-tools, utilities for android development including adb";
        }
    ];
in {
    imports = [
        ./git.nix
        ./keepassxc.nix
        ./gh-cli.nix
        ./nh.nix
        ./nix-index.nix
        ./btop.nix
    ];
    # tools which just need to be enabled with no other config
    options = let
        tools-options = builtins.listToAttrs (lib.map (x: {
            name = x.name;
            value = {
                enable = mkOption {
                    type = types.bool;
                    default = x.default;
                    description = "Enable ${x.name}. ${x.desc}";
                };
            };
        })
        tools);
    in {
        tools =
            {
                basic.enable = mkOption {
                    default = true;
                    type = types.bool;
                    description = "Enable a small list of very basic tools. Always want this on.";
                };
            }
            // tools-options;
    };
    config = let
        inherit
            (config.tools)
            basic
            ;
        basicList = with pkgs; [
            util-linux
            net-tools
            zip
            unzip
            file
            tree
        ];
        tool-pkgs = lib.map (x: x.pkg) (lib.filter (x: config.tools.${x.name}.enable) tools);
    in {
        home.packages =
            optionals basic.enable basicList
            ++ tool-pkgs;
    };
}
