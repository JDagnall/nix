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
    ];
    # tools which just need to be enabled with no other config
    options = {
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
    };
    config =
        let
            inherit (config.tools)
                pipenv
                mycli
                fd
                ripgrep
                cloc
                gzip
                btop
                brightnessctl
                ;
        in
        {
            home.packages =
                with pkgs;
                [
                    # some I wont bother with options
                    zip
                    unzip
                    file
                    tree
                ]
                ++ optionals pipenv.enable [ pkgs.pipenv ]
                ++ optionals mycli.enable [ pkgs.mycli ]
                ++ optionals fd.enable [ pkgs.fd ]
                ++ optionals ripgrep.enable [ pkgs.ripgrep ]
                ++ optionals cloc.enable [ pkgs.cloc ]
                ++ optionals gzip.enable [ pkgs.gzip ]
                ++ optionals btop.enable [ pkgs.btop ]
                ++ optionals brightnessctl.enable [ pkgs.brightnessctl ];
        };
}
