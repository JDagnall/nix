{
    pkgs,
    lib,
    config,
    ...
}: let
    inherit (lib) mkIf mkEnableOption mkOption optionals;
in {
    options = {
        langs.nix.enable =
            mkEnableOption {description = "Enable nix lang config.";};
        langs.nix.formatters = mkOption {
            default = true;
            type = lib.types.bool;
            description = "Installs a few formatters";
        };
    };
    config = let
        inherit (config.langs.nix) formatters;
        formatterList = with pkgs; [
            nixfmt
            alejandra
        ];
    in
        mkIf config.langs.python.enable {
            home.packages =
                []
                ++ optionals formatters formatterList;
        };
}
