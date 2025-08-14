{ lib, config, ... }:
{
    options = {
        tools.pipewire.enable = lib.mkEnableOption {
            description = "Pipe wire config is done in nix, this is just to signal that it is activated";
        };
    };
    config = lib.mkIf config.tools.pipewire.enable { };

}
