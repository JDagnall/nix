# this is definetly bad and I should not use this. use dev shells instead.
{
    # pkgs,
    lib,
    config,
    ...
}: let
    inherit (lib) mkEnableOption mkIf;
in {
    options = {
        langs.go.enable = mkEnableOption {description = "Enable go lang config.";};
    };
    config = mkIf config.langs.go.enable {
        # comes with gofmt
        programs.go = {
            enable = true;
            # env = {
            # 	GOPATH = []; # add to GOPATH
            # 	GOPRIVATE = []; # modules that should be considered private
            # };
            packages = []; # list of github links to go packages
        };
    };
}
