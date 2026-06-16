{
    pkgs,
    lib,
    config,
    ...
}: let
    inherit (lib) mkIf mkEnableOption;
in {
    options = {
        gaming.proton.enable = mkEnableOption {
            description = ''
                Enable Proton-GE. This is a fork that is supposed to be slightly better.
                The command protonup installs and updates it to the latest version.
            '';
        };
    };
    config = mkIf config.gaming.proton.enable {
        home.packages = with pkgs; [protonup-ng];
        home.sessionVariables = {
            STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\\\${HOME}/.steam/compatibilitytools.d";
        };
    };
}
