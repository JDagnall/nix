{
    # just doing the devshell as top level for now,
    # it could make use of the module system if it got more complicated but at the
    # moment it is unecesary
    # TODO: could do stuff in here to create a nixd config, so there is auto complete
    # for home-manager and input options.
    perSystem = {
        pkgs,
        # lib,
        ...
    }: {
        devShells.default = pkgs.mkShell {
            name = "nix";
            # packages = with pkgs; [];
            # env = {};
            # shellHook = '''';
        };
    };
}
