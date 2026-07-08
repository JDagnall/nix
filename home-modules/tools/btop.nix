{
    pkgs,
    lib,
    config,
    osConfig,
    ...
}: let
    cfg = config.tools.btop;
in {
    options = {
        tools.btop = {
            enable = lib.mkEnableOption "Enable btop";
            useGpuPkg = lib.mkEnableOption ''
                Install a GPU package for btop, that can monitor GPU's using an smi library.
                It will infer whether to install `btop-cuda` or `btop-rocm` from the nixos option `nvidia.enable`
            '';
        };
    };
    config = lib.mkIf cfg.enable {
        programs.btop = {
            enable = true;
            settings = {};
            package =
                if cfg.useGpuPkg && osConfig.nvidia.enable
                then pkgs.btop-cuda
                else if cfg.useGpuPkg
                then pkgs.btop-rocm
                else pkgs.btop;
        };
        stylix.targets.btop.enable = lib.mkIf config.stylix.enableHomeConfig true;
    };
}
