{
    pkgs,
    lib,
    config,
    ...
}:
let
    inherit (lib) optionals mkOption types;
in
{
    imports = [
        ./git.nix
        ./keepassxc.nix
        ./pipewire.nix
    ];
    # tools which just need to be enabled with no other config
    options = {
        tools.basic.enable = mkOption {
            default = true;
            type = types.bool;
            description = "Enable a small list of very basic tools. Always want this on.";
        };
        tools.pipenv.enable = mkOption {
            default = false;
            description = "Enable pipenv";
        };
        tools.mycli.enable = mkOption {
            default = false;
            description = "Enable mycli";
        };
        tools.fd.enable = mkOption {
            default = true;
            type = types.bool;
            description = "Enable fd";
        };
        tools.ripgrep.enable = mkOption {
            default = true;
            type = types.bool;
            description = "Enable ripgrep";
        };
        tools.cloc.enable = mkOption {
            default = true;
            type = types.bool;
            description = "Enable cloc";
        };
        tools.gzip.enable = mkOption {
            default = true;
            type = types.bool;
            description = "Enable gzip";
        };
        tools.zip.enable = mkOption {
            default = true;
            type = types.bool;
            description = "Enable zip and unzip";
        };
        tools.btop.enable = mkOption {
            default = true;
            type = types.bool;
            description = "Enable btop";
        };
        tools.brightnessctl.enable = mkOption {
            default = true;
            type = types.bool;
            description = "Enable brightnessctl. A screen brightness cli utility.";
        };
        tools.ncat.enable = mkOption {
            default = true;
            type = types.bool;
            description = "Enable netcat.";
        };
        tools.nmap.enable = mkOption {
            default = true;
            type = types.bool;
            description = "Enable nmap.";
        };
        tools.playerctl.enable = mkOption {
            default = true;
            type = types.bool;
            description = "Enable playerctl. For pause play keys.";
        };
    };
    config =
        let
            inherit (config.tools)
                basic
                pipenv
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
                ;
            basicList = with pkgs; [
                util-linux
                net-tools
                zip
                unzip
                file
                tree
            ];
        in
        {
            home.packages = [
                pkgs.zip
            ]
            ++ optionals basic.enable basicList
            ++ optionals pipenv.enable [ pkgs.pipenv ]
            ++ optionals mycli.enable [ pkgs.mycli ]
            ++ optionals fd.enable [ pkgs.fd ]
            ++ optionals ripgrep.enable [ pkgs.ripgrep ]
            ++ optionals cloc.enable [ pkgs.cloc ]
            ++ optionals gzip.enable [ pkgs.gzip ]
            ++ optionals btop.enable [ pkgs.btop ]
            ++ optionals brightnessctl.enable [ pkgs.brightnessctl ]
            ++ optionals ncat.enable [ pkgs.netcat ]
            ++ optionals nmap.enable [ pkgs.nmap ]
            ++ optionals playerctl.enable [ pkgs.playerctl ];
        };
}
