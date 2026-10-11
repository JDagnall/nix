# waiting for this https://github.com/NixOS/nixpkgs/pull/427541 to get merged,
# in order to fix stdin breaking on terminal sessions.
{...}: {
    flake.modules.nixos.ly = {...}: let
    in {
        services.greeter.ly = {
            enable = true;
            # package = pkgs.ly;
            # x11Support = true;
            settings = {
            };
        };
    };
}
