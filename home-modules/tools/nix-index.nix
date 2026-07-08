{
    pkgs,
    lib,
    config,
    inputs,
    ...
}: {
    options = {
        tools.nix-index.enable = lib.mkEnableOption "Enable the nix-index tool. Which allows you to search for nix binaries in the nix store and nixpkgs. Replaces command-not-found.";
        tools.nix-index.comma.enable = lib.mkEnableOption "Enable comma, a tool that uses nix index to download / retreive pkgs from the store or nixpkgs and run them";
    };
    # importing this input so the premade index can be downloaded as a package, this way
    # it doesn't need to be built locally, which takes a minute
    imports = [inputs.nix-index-database.homeModules.default];
    config = lib.mkIf config.tools.nix-index.enable {
        programs.command-not-found.enable = false;
        programs.nix-index = {
            enable = true;
            enableZshIntegration = config.shell.zsh.enable;
        };
        home.packages = lib.mkIf config.tools.nix-index.comma.enable [pkgs.comma];
    };
}
