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
        langs.nix.enable = mkEnableOption {
            default = false;
            description = "Enable nix config";
        };
        langs.nix.formatters = mkOption {
            default = true;
            type = lib.types.bool;
            description = "Installs a few formatters";
        };
    };
    config =
        let
            inherit (config.langs.nix) formatters;
            formatterList = with pkgs; [
                nixfmt-rfc-style
                alejandra
            ];

        in
        mkIf config.langs.python.enable {
            home.packages = [
            ] ++ (if formatters then formatterList else [ ]);
        };
}
