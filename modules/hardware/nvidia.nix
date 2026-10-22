{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.nvidia = {
        pkgs,
        config,
        ...
    }: let
        inherit (lib) mkIf;
    in {
        imports = with self.modules.nixos; [gpu];
        options = {
            nvidia = {
                cuda.enable = lib.mkEnableOption "Enable CUDA.";
            };
        };
        config = {
            my.hardware.gpu = {
                type = "nvidia";
            };
            # This is usually not needed as most modules that would use it
            # set it. However in the case of headless servers using GPU's
            # It may be necesary.
            hardware.graphics.enable = true;
            hardware.nvidia = {
                modesetting.enable = true;
                # not using this at the moment, if stuff crashed waking up from sleep, try to use it
                powerManagement.enable = true;
                # open source kernel module, still in development, might be worth a try
                open = true;
                # graphical settings menu
                nvidiaSettings = false;
                # could be stable, production, beta or latest
                branch = "stable";
            };
            services.xserver.videoDrivers = ["nvidia"];
            nixpkgs.config.cudaSupport = config.nvidia.cuda.enable;
            nix.settings = mkIf config.nvidia.cuda.enable {
                substituters = [
                    "https://cache.nixos-cuda.org"
                ];
                trusted-public-keys = [
                    "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
                ];
            };
            # nvidia drivers are proprietary
            # predicate that allows packages with the cuda license
            my.allowedUnfreePkgPredicates = lib.optional config.nvidia.cuda.enable pkgs._cuda.lib.allowUnfreeCudaPredicate;
        };
    };
}
