{...}: {
    flake.modules.homeManager.zoxide = {...}: {
        config = {
            programs.zoxide = {
                enable = true;
                options = ["--cmd cd" "--hook pwd"];
            };
            home.sessionVariables = {
                _ZO_DATA_DIR = "$HOME/.local/share/zoxide";
                _ZO_FZF_OPTS = "--no-preview";
                _ZO_MAXAGE = 10000;
                _ZO_ECHO = 0; # whether to print found directory
                _ZO_RESOLVE_SYMLINKS = 1;
                _ZO_EXCLUDE_DIRS = "$HOME/.cargo;$HOME/.vim";
            };
        };
    };
}
