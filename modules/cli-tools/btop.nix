{
    self,
    lib,
    ...
}: {
    flake.modules.homeManager.btop = {
        pkgs,
        config,
        osConfig,
        ...
    }: let
        # cfg = config.my.tools.btop;
    in {
        imports = with self.modules.homeManager; [stylix-interface];
        config = let
            # if the gpu options in nixos, are not set then its just assumed
            # as not present
            gpuType = osConfig.my.hardware.gpu.type or null;
        in {
            programs.btop = {
                enable = true;
                settings = {};
                package =
                    if gpuType == "nvidia"
                    then pkgs.btop-cuda
                    else if gpuType == "amd"
                    then pkgs.btop-rocm
                    else pkgs.btop;
            };
            stylix.targets.btop.enable = lib.mkIf config.my.stylix.enabled;
        };
    };
}
