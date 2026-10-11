{inputs, ...}: {
    # this is a top level import that will always be evaluated.
    # It simply import the flake-parts flakeModules modules
    imports = [inputs.flake-parts.flakeModules.modules];
}
