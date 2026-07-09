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
        # wivrn will need users to have these configuration files
        xdg.configFile = lib.mkIf osConfig.gaming.vr.wivrn.enable {
            "openxr/1/active_runtime.json".source = "${pkgs.monado}/share/openxr/1/openxr_monado.json";
            "openvr/openvrpaths.vrpath".text = let
                steamDir = "${config.xdg.dataHome}/Steam";
            in
                builtins.toJSON {
                    version = 1;
                    jsonid = "vrpathreg";
                    external_drivers = null;
                    config = ["${steamDir}/config"];
                    log = ["${steamDir}/logs"];
                    runtime = [
                        "${pkgs.xrizer}/lib/xrizer"
                        # or
                        # "${pkgs.opencomposite}/lib/opencomposite"
                    ];
                };
        };
    };
}
