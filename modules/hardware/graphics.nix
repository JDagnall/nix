# interface pattern for knowing what/if GPU is configured
{lib, ...}: {
    flake.modules.nixos.gpu = {config, ...}: let
        cfg = config.my.hardware.gpu;
    in {
        key = "my/nixos/gpu";
        options.my.hardware.gpu = {
            type = lib.mkOption {
                type = with lib.types; nullOr (enum ["nvidia" "amd"]);
                default = null;
                description = ''
                    The type of GPU, that being nvidia or AMD, null is for no gpu configured
                    or enabled, meaning hardware acceleration is not going to be enabled for
                    various configs.
                '';
            };
            devPath = lib.mkOption {
                type = with lib.types; nullOr str;
                default =
                    if cfg.type == "nvidia"
                    then "/dev/nvidia0"
                    else if cfg.type == "amd"
                    then "/dev/dri/renderD128"
                    else null;
                description = "The path to the actual GPU device, may differ per device.";
            };
        };
    };
}
