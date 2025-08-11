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
            description = "enable pipenv";
        };
        tools.mycli.enable = mkOption {
            default = false;
            description = "enable mycli";
        };
        tools.fd.enable = mkOption {
            default = true;
            type = types.bool;
            description = "enable fd";
        };
        tools.ripgrep.enable = mkOption {
            default = true;
            type = types.bool;
            description = "enable ripgrep";
        };
        tools.cloc.enable = mkOption {
            default = true;
            type = types.bool;
            description = "enable cloc";
        };
        tools.gzip.enable = mkOption {
            default = true;
            type = types.bool;
            description = "enable gzip";
        };
        tools.zip.enable = mkOption {
            default = true;
            type = types.bool;
            description = "enable zip and unzip";
        };
        tools.btop.enable = mkOption {
            default = true;
            type = types.bool;
            description = "enable btop";
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
                ++ optionals btop.enable [ pkgs.btop ];
        };
}
