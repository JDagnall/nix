{inputs, ...}: {
    flake.modules.homeManager.nix-index = {pkgs, ...}: {
        # importing this input so the premade index can be downloaded as a package, this way
        # it doesn't need to be built locally, which takes a minute
        # the module should replace the default package with a pre built one
        imports = [inputs.nix-index-database.homeModules.default];
        config = {
            programs.command-not-found.enable = false;
            programs.nix-index = {
                enable = true;
                symlinkToCacheHome = true; # should make it so comma uses it automatically
            };
            # to execute a command exported in nixpkgs without making a nix-shell
            home.packages = [pkgs.comma];
        };
    };
}
