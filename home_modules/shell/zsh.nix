{
    pkgs,
    lib,
    config,
    ...
}:
let
    inherit (lib)
        mkIf
        mkEnableOption
        mkOrder
        mkMerge
        ;
in
{
    options = {
        shell.zsh.enable = mkEnableOption {
            default = false;
            description = "enable zsh config";
        };
        shell.zsh.dircolors.enable = mkEnableOption {
            default = false;
            description = "enable directory colors config";
        };
        shell.zsh.direnv.enable = mkEnableOption {
            default = false;
            description = "enable direnv config";
        };
    };

    config = mkIf config.shell.zsh.enable {
        programs.zsh = {
            enable = true;
            # plugins just sources the files pointed too by its elements
            plugins = [
                {
                    name = "powerlevel10k-config";
                    src = ./.;
                    file = ".p10k.zsh";
                }
                {
                    name = "zsh-powerlevel10k";
                    src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
                    file = "powerlevel10k.zsh-theme";
                }
                {
                    name = "fzf-tab";
                    src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
                }
            ];

            enableCompletion = true;
            autosuggestion.enable = true;
            syntaxHighlighting = {
                enable = true;
                highlighters = [
                    "brackets"
                    "cursor"
                ];
                # patterns = {};
                # styles = {};
            };
            # cd when a directory name is type into the terminal
            autocd = true;
            # zsh completion initialisation command
            completionInit = "autoload -U compinit && compinit";
            # "vimcd" is an option
            defaultKeymap = "emacs";

            dirHashes = {
                NVIM = "$HOME/.config/nvim";
            };

            #dotDir = ""; # where .zshrc goes

            history = {
                append = true;
                expireDuplicatesFirst = true;
                extended = true; # save timestamps
                findNoDups = true;
                ignoreAllDups = true;
                ignoreDups = true;
                ignoreSpace = true;
                #path = "$HOME/.zsh_history";
                save = 5000; # num of lines to save
                saveNoDups = true;
                share = true; # persist history between sessions
                size = 5000;
            };

            oh-my-zsh = {
                enable = true;
                plugins = [
                    "git"
                    "sudo"
                    "command-not-found"
                    # "tmux"
                ];
            };
            initContent =
                let
                    # must be excecuted first
                    initFirst = mkOrder 500 ''
                        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
                            source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
                        fi
                    '';

                    # random options that cant be set in home-manager
                    initExtra = mkOrder 1000 ''
                        setopt GLOB_DOTS
                        # push prev dir onto dir stack
                        setopt autopushd

                        # completion remove case-sensitivity
                        zstyle ':completion:*' special-dirs true
                        # hidden files in zsh completion
                        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
                        # completions add colors
                        zstyle ':completion:*' list-colors "\''${(s.:.)LS_COLORS}"
                        # no default completion menu
                        zstyle ':completion:*' menu no
                        # FZF-tab zstyle options
                        zstyle ':fzf-tab:complete:*' fzf-preview "$FZF_TAB_PREVIEW"
                        zstyle ':fzf-tab:complete:*' fzf-flags "--height=~15"
                        zstyle ':fzf-tab:*' use-fzf-default-opts yes

                        bindkey -e
                        bindkey '^f' autosuggest-accept
                        bindkey '^p' history-search-backward
                        bindkey '^n' history-search-forward
                    '';
                in
                mkMerge [
                    initFirst
                    initExtra
                ]; # merges two order objects

            shellAliases = {
                ls = "ls -lahH --color=auto";
                py = "python3";
                sudo = "sudo ";
                c = "clear";
                cls = "clear";

                grep = "grep --color=auto";
                fgrep = "fgrep --color=auto";
                egrep = "egrep --color=auto";
                diff = "diff --color=auto";
                ip = "ip --color=auto";
                ll = "ls -l";
                la = "ls -A";
                l = "ls -CF";
            };

        };

        # directory ls colors
        programs.dircolors = mkIf config.shell.zsh.dircolors.enable {
            enable = true;
            enableZshIntegration = true;
            # just fixes annoying ls colors for file systems without perms
            settings = {
                OTHER_WRITABLE = "01;33";
                STICKY_OTHER_WRITABLE = "01;31";
                CAPABILITY = "00";
            };

        };

        programs.direnv = mkIf config.shell.zsh.direnv.enable {
            enable = true;
            enableZshIntegration = true;
            # config = {}; # written to .toml config file
            silent = false;
        };

        home = {
            shell.enableZshIntegration = true;
            packages = with pkgs; [
                zsh
                zsh-fzf-tab
                zsh-syntax-highlighting
                zsh-completions
                zsh-autosuggestions
                zsh-powerlevel10k
                direnv
            ];
        };
    };

}
