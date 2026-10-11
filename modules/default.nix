# nixos config always included for all hosts
{lib, ...}: {
    flake.modules.nixos.default = {config, ...}: {
        options = {
            allowedUnfreePkgNames = lib.mkOption {
                type = with lib.types; listOf str;
                default = [];
                description = "Allowed list of unfree pkg names, that will be allowed with the unfree predicate";
            };
            allowedUnfreePkgPredicates = lib.mkOption {
                type = with lib.types; listOf (functionTo bool);
                default = [];
                description = ''
                    Predicate functions which accept a pkg as an input.
                    If any of them return true the pkg is accepted.
                '';
            };
        };
        config = {
            # predicate that allows any pkg names in allowedUnfreePkgNames
            allowedUnfreePkgPredicates = [
                (pkg: builtins.elem (lib.getName pkg) config.allowedUnfreePkgNames)
            ];
            # runs pred(pkg) for each pred, if any return true the predicate is true
            nixpkgs.config.allowUnfreePredicate = pkg: lib.any (pred: pred pkg) config.allowedUnfreePkgPredicates;
            # kernel modules that should be turned off for every host
            boot.blacklistedKernelModules = [
                "algif_aead" # CVE: 2026-31431
            ];
            nix.settings = {
                auto-optimise-store = true;
            };
        };
    };
}
