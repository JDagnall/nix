# THESE ARE NOT REAL CONFIGS. These are just semantic options set too say that these services which are configured in nixos, are on
{ lib, ... }:
let
    inherit (lib) types mkOption;
in
{
    options = {
        pipewire.enabled = mkOption {
            type = types.bool;
            default = true;
            description = "Pipe wire config is done in nix, this is just to signal that it is activated";
        };
        blueman.enabled = mkOption {
            type = types.bool;
            default = true;
            description = "Blueman config is done in nix, this is just to signal that it is activated";
        };
        network-manager.enabled = mkOption {
            type = types.bool;
            default = true;
            description = "Network manager config is done in nix, this is just to signal that it is activated";
        };
    };

}
