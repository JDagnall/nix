{
    # pkgs,
    lib,
    config,
    ...
}:
let
    inherit (lib) mkIf mkEnableOption;
in
{
    options = {
        shell.zoxide.enable = mkEnableOption {
            default = false;
            description = "enable zoxide config";
        };
    };
    config = mkIf config.shell.zoxide.enable {
        programs.zoxide = {
            enable = true;
            enableZshIntegration = config.shell.zsh.enable;
            options = [
                "--cmd cd"
                "--hook pwd"
            ];
        };
        programs.zsh.sessionVariables = mkIf config.shell.zsh.enable {
            _ZO_DATA_DIR = "$HOME/.local/share/zoxide";
            _ZO_FZF_OPTS = "--no-preview";
            _ZO_MAXAGE = 10000;
            _ZO_ECHO = 0; # whether to print found directory
            _ZO_RESOLVE_SYMLINKS = 1;
            _ZO_EXCLUDE_DIRS = "$HOME/.cargo;$HOME/.vim";
        };
    };
}
