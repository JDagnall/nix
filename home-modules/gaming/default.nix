{
    pkgs,
    lib,
    config,
    osConfig,
    ...
}: let
    inherit (lib) optionals;
in {
    imports = [
        ./proton.nix
        ./lutris.nix
        ./mangohud.nix
        ./prism.nix
    ];
    options = {
        gaming.heroic.enable = lib.mkEnableOption "Install heroic";
        gaming.protonplus.enable = lib.mkEnableOption "Install protonplus";
    };
    config = let
        inherit (config.gaming) heroic protonplus;
    in {
        home.packages =
            []
            ++ optionals heroic.enable [pkgs.heroic]
            ++ optionals protonplus.enable [pkgs.protonplus];
        xdg.configFile = lib.mkIf osConfig.gaming.vr.wivrn.enable {
            "openxr/1/active_runtime.json".source = "${pkgs.wivrn}/share/openxr/1/openxr_wivrn.json";
            # wivrn does this now
            # "openvr/openvrpaths.vrpath".text = let
            #     steamDir = "${config.xdg.dataHome}/Steam";
            #     compat = osConfig.gaming.vr.wivrn.compatLib;
            # in
            #     builtins.toJSON {
            #         version = 1;
            #         jsonid = "vrpathreg";
            #         external_drivers = null;
            #         config = ["${steamDir}/config"];
            #         log = ["${steamDir}/logs"];
            #         runtime = [
            #             "${pkgs.${compat}}/lib/${compat}"
            #         ];
            #     };
        };
    };
}
