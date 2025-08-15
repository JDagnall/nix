{
    pkgs,
    lib,
    config,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
in
{
    options = {
        shell.bat.enable = mkEnableOption {
            default = false;
            description = "enable bat configuration";
        };
    };
    config = mkIf config.shell.bat.enable {
        programs.bat = {
            enable = true;
            extraPackages = with pkgs.bat-extras; [
                batman
                batdiff
                batpipe
                batgrep
                prettybat
            ];
            # syntaxes = {}; extra  syntaxes
            # themes = {
            #   catppuccinMocha = {
            #     src = pkgs.fetchFromGitHub {
            #       owner = "catppuccin";
            #       repo = "bat";
            #       rev = "6810349b28055dce54076712fc05fc68da4b8ec0";
            #       hash = "sha256-lJapSgRVENTrbmpVyn+UQabC9fpV1G1e+CdlJ090uvg=";
            #     };
            #     file = "themes/Catppuccin Mocha.tmTheme";
            #   };
            # };
            config = {
                # theme = "catppuccinMocha";
                style = "plain";
                paging = "never";
                color = "always";
            };
        };
        programs.zsh.shellAliases = mkIf config.shell.zsh.enable {
            man = "batman --paging=always";
            cat = "bat";
        };
        stylix.targets.bat.enable = config.stylix.enableHomeConfig;
    };

}
