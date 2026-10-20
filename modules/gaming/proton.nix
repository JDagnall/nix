{...}: {
    flake.modules.homeManager.proton = {pkgs, ...}: let
    in {
        config = {
            home.packages = with pkgs; [protonup-ng];
            home.sessionVariables = {
                STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\\\${HOME}/.steam/compatibilitytools.d";
            };
        };
    };
}
