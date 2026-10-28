{lib, ...}: {
    flake.modules.homeManager.zsh = {
        pkgs,
        # config,
        ...
    }: let
    in {
        options = {
            # my.shells.zsh ={};
        };

        config = let
            # cfg = config.my.shells.zsh;
        in {
            programs.zsh = {
                enable = true;
                # plugins just sources the files pointed too by its elements
                plugins = [
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
                    enable = false; # did I ever actually use this
                    plugins = [
                        "git"
                        "sudo"
                        "command-not-found"
                        # "tmux"
                    ];
                };
                initContent = let
                    # # must be excecuted first
                    initFirst =
                        lib.mkOrder 500 ''
                        '';
                    # random options that cant be set in home-manager
                    initOptions = lib.mkOrder 1000 ''
                        setopt GLOB_DOTS
                        # push prev dir onto dir stack
                        setopt autopushd

                        # Load a command to edit the current line in $EDITOR
                        autoload -Uz edit-command-line
                        zle -N edit-command-line
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
                        bindkey '^n' edit-command-line
                    '';
                    initExtra =
                        # has nix develop respect $SHELL
                        lib.mkOrder 1000 ''
                            nix() {
                                if [[ $1 == "develop" ]]; then
                                    shift
                                    command nix develop -c $SHELL "$@"
                                else
                                    command nix "$@"
                                fi
                            }

                        '';
                in
                    lib.mkMerge [
                        initFirst
                        initOptions
                        initExtra
                    ];

                # shellAliases = {
                # };
            };

            programs.starship = {
                enable = true;
                enableZshIntegration = true;
                validateFiles.config = true;
                # configPath = ;
                presets = [
                    # should maybe check stylix for this but im just gonna assume that nerd fonts are installed
                    "nerd-font-symbols"
                    "pure-preset" # minimal defaults
                ];
                settings = {
                    add_newline = false;
                    format = ''
                        $directory$git_branch $git_status $git_state
                        $character
                    '';
                    right_format = lib.concatStrings [
                        "$username"
                        "$hostname"
                        "$cmd_duration"
                        "$golang"
                        "$rust"
                        "$python"
                        "$zig"
                        "$direnv"
                        "$nix_shell"
                        "$sudo"
                    ];
                    character = {
                        success_symbol = "[❯](gray)";
                        error_symbol = "[❯](red)";
                        vimcmd_symbol = "[❮](green)";
                    };
                    nix_shell = {
                        format = ''[$symbol$name]($style) '';
                    };
                    git_branch = {
                        style = "bold green";
                    };
                    git_status = {
                        untracked = "?$count";
                        modified = "+$count";
                        staged = "^$count";
                    };
                };
            };

            # directory ls colors
            programs.dircolors = {
                enable = true;
                enableZshIntegration = true;
                # just fixes annoying ls colors for file systems without perms
                settings = {
                    OTHER_WRITABLE = "01;33";
                    STICKY_OTHER_WRITABLE = "01;31";
                    CAPABILITY = "00";
                };
            };

            home = {
                shell.enableZshIntegration = true;
                sessionVariables.SHELL = "zsh";
                packages = with pkgs; [
                    zsh
                    zsh-fzf-tab
                    zsh-syntax-highlighting
                    zsh-completions
                    zsh-autosuggestions
                    zsh-powerlevel10k
                ];
            };
        };
    };
}
