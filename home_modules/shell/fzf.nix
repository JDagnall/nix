{ pkgs, lib, config, ... }:
let inherit (lib) mkIf mkEnableOption;
in {
  options = {
    shell.fzf.enable = mkEnableOption {
      default = false;
      description = "enable fzf config";
    };
  };
  # mkIf config.shell.fzf.enable
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
      enableZshIntegration = config.shell.zsh.enable;
      colors = {
        fg = "#cdd6f4";
        "fg+" = "#cdd6f4";
        bg = "#1e1e2e";
        "bg+" = "#313244";
        selected-bg = "#45475a";
        hl = "#f38ba8";
        "hl+" = "#f38ba8";
        spinner = "#f5e0dc";
        header = "#f38ba8";
        info = "#cba6f7";
        pointer = "#f5e0dc";
        marker = "#b4befe";
        prompt = "#cba6f7";
      };
      defaultCommand = defaultCmd;
      defaultOptions = defaultOpts;
      # ALT-C directory search
      changeDirWidgetCommand =
        "fd --type d --hidden --follow --color never --exclude '.git'";
      changeDirWidgetOptions = [ "--preview='tree -C {}'" ];
      # CTRL-T file search
      fileWidgetCommand = defaultCmd;
      fileWidgetOptions = [ "--preview ${preview}" ];
      # CTRL-R history  search
      historyWidgetOptions = [ "--no-preview" ];
    };

    programs.zsh.sessionVariables = mkIf config.shell.zsh.enable {
      FZF_PREVIEW = preview;
      FZF_TAB_PREVIEW = fzf-tab-preview;
    };

    home.packages = with pkgs; [ fd tree ];
  };
}
