{self, ...}: {
    flake.modules.homeManager.fzf = {
        pkgs,
        config,
        ...
    }: {
        imports = with self.modules.homeManager; [stylix-interface];
        config = let
            defaultCmd = "fd --hidden --follow --color never --exclude '.git' -d 5";
            defaultOpts = [
                "--layout='reverse'"
                "--border='rounded'"
                "--height='~15'"
                "--prompt='> '"
                "--marker='>'"
                "--pointer='◆'"
                "--separator='─'"
                "--scrollbar='│'"
                "--layout='reverse'"
                "--info='right'"
                "--tmux"
            ];
            preview = ''
                if [[ -d {} ]]; then
                    if [[ -n $FZF_PREVIEW_LINES ]]; then
                        tree -C {} | head -$FZF_PREVIEW_LINES
                    else
                        tree -C {}
                    fi
                elif [[ -r {} ]]; then
                    if [[ -n $FZF_PREVIEW_LINES ]]; then
                        bat --color always --line-range 1:$FZF_PREVIEW_LINES {}
                    else
                        bat --color always {}
                    fi
                else
                    file {}
                fi
            '';
            fzf-tab-preview = ''
                if [[ -d \"$realpath\" ]]; then
                    if [[ -n $FZF_PREVIEW_LINES ]]; then
                        tree -C \"$realpath\" | head -$FZF_PREVIEW_LINES
                    else
                        tree -C \"$realpath\"
                    fi
                elif [[ -r \"$realpath\" ]]; then
                    if [[ -n $FZF_PREVIEW_LINES ]]; then
                        bat --color always --line-range 1:$FZF_PREVIEW_LINES \"$realpath\"
                    else
                        bat --color always \"$realpath\"
                    fi
                else
                    file \"$realpath\"
                fi
            '';
        in {
            programs.fzf = {
                enable = true;
                enableZshIntegration = config.programs.zsh.enable;
                defaultCommand = defaultCmd;
                defaultOptions = defaultOpts;
                # ALT-C directory search
                changeDirWidget = {
                    command = "${pkgs.fd}/bin/fd --type d --hidden --follow --color never --exclude '.git'";
                    options = ["--preview='${pkgs.tree}/bin/tree -C {}'"];
                };
                # CTRL-T file search
                fileWidget = {
                    command = defaultCmd;
                    options = ["--preview ${preview}"];
                };
                # CTRL-R history  search
                historyWidget = {
                    options = ["--no-preview"];
                };
            };
            stylix.targets.fzf.enable = config.my.stylix.enabled;
            home.sessionVariables = {
                FZF_PREVIEW = preview;
                FZF_TAB_PREVIEW = fzf-tab-preview;
            };
        };
    };
}
