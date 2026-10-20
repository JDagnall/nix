# nixos config always included for all hosts
{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.base = {pkgs, ...}: {
        imports = with self.modules.nixos; [
            unfree-predicates
            locale-settings
            nix-settings
            garbage-collector
        ];
        config = {
            # kernel modules that should be turned off for every host
            boot.blacklistedKernelModules = [
                "algif_aead" # CVE: 2026-31431
            ];
            boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
        };
    };
    flake.modules.nixos.unfree-predicates = {config, ...}: {
        options = {
            my = {
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
        };
        config = {
            # predicate that allows any pkg names in allowedUnfreePkgNames
            my.allowedUnfreePkgPredicates = [
                (pkg: builtins.elem (lib.getName pkg) config.my.allowedUnfreePkgNames)
            ];
            # runs pred(pkg) for each pred, if any return true the predicate is true
            nixpkgs.config.allowUnfreePredicate = pkg: lib.any (pred: pred pkg) config.my.allowedUnfreePkgPredicates;
        };
    };

    flake.modules.nixos.locale-settings = {...}: {
        # Select internationalisation properties.
        i18n.defaultLocale = "en_GB.UTF-8";

        i18n.extraLocaleSettings = {
            LC_ADDRESS = "en_AU.UTF-8";
            LC_IDENTIFICATION = "en_AU.UTF-8";
            LC_MEASUREMENT = "en_AU.UTF-8";
            LC_MONETARY = "en_AU.UTF-8";
            LC_NAME = "en_AU.UTF-8";
            LC_NUMERIC = "en_AU.UTF-8";
            LC_PAPER = "en_AU.UTF-8";
            LC_TELEPHONE = "en_AU.UTF-8";
            LC_TIME = "en_AU.UTF-8";
        };

        console = {
            font = "Lat2-Terminus16";
            keyMap = "us";
            #useXkbConfig = true; # use xkb.options in tty.
        };
    };
    flake.modules.nixos.garbage-collector = {...}: {
        # garbage collector
        nix.gc = {
            automatic = true;
            dates = "weekly";
            persistent = true;
            randomizedDelaySec = "10min";
            options = "-d";
        };
    };

    flake.modules.nixos.nix-settings = {...}: {
        nix.settings = {
            experimental-features = [
                "nix-command"
                "flakes"
            ];
            auto-optimise-store = true;
        };
    };
}
