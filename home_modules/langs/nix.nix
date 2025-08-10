{
    pkgs,
    lib,
    config,
    ...
}:
let
    inherit (lib) mkIf mkEnableOption;
in
{
    options = {
        langs.nix.enable = mkEnableOption {
            default = false;
            description = "Enable nix config";
        };
        langs.nix.formatters = mkEnableOption {
            default = true;
            description = "Installs a few formatters";
        };
    };
    config =
        let
            inherit (config.langs.python) formatters packages;
            formatterList = with pkgs; [
                nixfmt
                alejandra
            ];

        in
        mkIf config.langs.python.enable {
            home.packages = [
            ] ++ (if formatters then formatterList else [ ]);
        };
}
