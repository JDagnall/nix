# this is definetly bad and I should not use this. use dev shells instead.
{
    pkgs,
    lib,
    config,
    ...
}: let
    inherit (lib) mkIf mkOption mkEnableOption optionals;
in {
    options = {
        langs.rust.enable = mkEnableOption "rust";
        langs.rust.formatters = mkOption {
            type = lib.types.bool;
            default = true;
            description = "Include formatter in rust config.";
        };
    };
    config = let
        inherit (config.langs.rust) formatters;
    in
        mkIf config.langs.rust.enable {
            home.packages = with pkgs; [rustc cargo] ++ optionals formatters [rustfmt clippy];
        };
}
