# THESE ARE NOT REAL CONFIGS. These are just semantic options set too say that these services which are configured in nixos, are on
{ lib, ... }:
let
    inherit (lib) types mkOption;
in
{
    options = {
        nixos-settings.pipewire.enabled = mkOption {
            type = types.bool;
            description = "Pipe wire config is done in nix, this is just to signal that it is activated";
        };
        nixos-settings.blueman.enabled = mkOption {
            type = types.bool;
            description = "Blueman config is done in nix, this is just to signal that it is activated";
        };
        nixos-settings.network-manager.enabled = mkOption {
            type = types.bool;
            description = "Network manager config is done in nix, this is just to signal that it is activated";
        };
        nixos-settings.fprintd.enabled = mkOption {
            type = types.bool;
            description = "Fprintd config is done in nix, this is just to signal that it is activated";
        };
        nixos-settings.hyprland-uwsm.enabled = mkOption {
            type = types.bool;
            description = "Whether UWSM is being used for hyprland, this is just to signal that it is activated";
        };
    };

}
