{
# pkgs,
lib, config, ... }:
let inherit (lib) mkIf mkEnableOption;
in {
  options = {
    tools.git.enable = mkEnableOption {
      default = false;
      description = "enable git config";
    };
    tools.git.lfs.enable = mkEnableOption {
      default = false;
      description = "enable lfs and lfs config for git";
    };
  };

  config = mkIf config.tools.git.enable {
    programs.git = {
      enable = true;
      attributes = [ ];
      diff-so-fancy = {
        enable = true;
        changeHunkIndicators = true;
        markEmptyLines = true;
        pagerOpts = [ ];
      };
      # hooks = {};
      ignores = [
        # Python
        ".pytest_cache/"
        "__pycache__/"
      ];
      lfs.enable = config.tools.git.lfs.enable;
      userName = "James Dagnall";
      userEmail = "james.t.dagnall@gmail.com";
      # translated to toml config files
      extraConfig = {
        core = {
          editor = "nvim";
          sshCommand = "ssh -i ~/.ssh/key";
          whitespace = "error"; # threat trailing whitespace as error
        };
        init = { defaultBranch = "main"; };
        blame = {
          coloring = "highlightRecent";
          date = "relative";
        };
        diff = {
          context = 3; # less context in diffs
          renames = "copies"; # detect copies as renames in diffs
          interHunkContext = "10"; # merge near hunks in diffs
        };
        log = {
          abbrevCommit = true; # short commits
        };
        status = {
          branch = true;
          short = true;
          showStash = true;
          showUntrackedFiles = "all";
        };
        pager = {
          branch = false; # no need to user pager for git branch
          diff = "diff-so-fancy | less"; # diff-so-fancy as pager
        };
        push = {
          autoSetupRemote = true; # easier to push new branches
          default = "current"; # push only current branch by default
        };
        pull = {
          # rebase = true # rebase not up to date commits when pulling
          ff = "only"; # dont pull if there is a merge conflict
        };
        rebase = { autostash = true; };
        interactive = {
          # diffFilter = "diff-so-fancy --patch";
          singlekey = true;
        };
      };
    };

    programs.zsh.shellAliases = mkIf config.shell.zsh.enable {
      gap = "git add --patch";
      gs = "git status";
      gl =
        "git log --all --graph --pretty=format:'%C(magenta)%h %C(white) %an  %ar%C(blue)  %D%n%s%n'";
      gd = "git diff --output-indicator-new=' '  --output-indicator-old=' '";
      gch = "git checkout";
    };

    # home.packages = with pkgs; [
    #     git
    #     diff-so-fancy
    #     git-lfs
    # ]
  };
}
