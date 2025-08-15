{
    pkgs,
    lib,
    config,
    ...
}:
let
    inherit (lib) mkIf mkEnableOption mkOption;
in
{
    options = {
        langs.python.enable = mkEnableOption {
            default = false;
            description = "Enable python, installs 3.12";
        };
        langs.python.formatters = mkOption {
            default = true;
            type = lib.types.bool;
            description = "Installs a few formatters";
        };
        langs.python.packages = mkOption {
            default = true;
            type = lib.types.bool;
            description = "Installs some often used packages";
        };
    };
    config =
        let
            inherit (config.langs.python) formatters packages;
            formatterList = with pkgs; [
                ruff
                python312Packages.autopep8
            ];
            packageList = with pkgs.python312Packages; [
                matplotlib
                pandas
                requests
            ];

        in
        mkIf config.langs.python.enable {
            home.packages =
                with pkgs;
                [
                    python312
                    # python314 # multiple python versions cause collisions
                ]
                ++ (if formatters then formatterList else [ ])
                ++ (if packages then packageList else [ ]);
        };
}
