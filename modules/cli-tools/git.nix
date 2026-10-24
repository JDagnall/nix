{
    self,
    lib,
    ...
}: {
    flake.modules.homeManager.git = {
        pkgs,
        config,
        ...
    }: {
        imports = with self.modules.homeManager; [stylix-interface];
        key = "my/home/git";
        options = {
            my.cli-tools.git = {
                lfs.enable = lib.mkEnableOption {
                    default = false;
                    description = "enable lfs and lfs config for git";
                };
                pager = lib.mkOption {
                    type = lib.types.enum [
                        "delta"
                        "diff-so-fancy"
                        "diffnav"
                    ];
                    default = "delta";
                };
            };
        };

        config = let
            cfg = config.my.cli-tools.git;
        in {
            programs.git = {
                enable = true;
                attributes = [];

                # hooks = {};
                ignores = [
                    # Python
                    ".pytest_cache/"
                    "__pycache__/"
                ];
                lfs.enable = cfg.lfs.enable;
                settings = {
                    core = {
                        editor = config.home.sessionVariables.EDITOR;
                        sshCommand = "ssh -i ~/.ssh/key";
                        whitespace = "error"; # threat trailing whitespace as error
                        pager = lib.mkIf (cfg.pager == "diffnav") "${pkgs.diffnav}/bin/diffnav";
                    };
                    init = {
                        defaultBranch = "main";
                    };
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
                    };
                    push = {
                        autoSetupRemote = true; # easier to push new branches
                        default = "current"; # push only current branch by default
                    };
                    pull = {
                        # rebase = true # rebase not up to date commits when pulling
                        ff = "only"; # dont pull if there is a merge conflict
                    };
                    rebase = {
                        autostash = true;
                    };
                    interactive = {
                        # diffFilter = "diff-so-fancy --patch";
                        singlekey = true;
                    };
                };
            };

            programs.diff-so-fancy = lib.mkIf (cfg.pager == "diff-so-fancy") {
                enable = true;
                settings = {
                    changeHunkIndicators = true;
                    markEmptyLines = true;
                };
                pagerOpts = ["--quit-if-one-screen"];
            };

            programs.delta =
                lib.mkIf (cfg.pager == "delta" || cfg.pager == "diffnav")
                {
                    enable = true;
                    enableGitIntegration =
                        if (cfg.pager == "delta")
                        then true
                        else false;
                    options = {
                        navigate = true;
                        diff-so-fancy = false; # emulate diff-so-fancy style
                        dark = true;
                        line-numbers = false;
                        side-by-side = false;
                        color-only = false; # no links etc, just highlighting
                        # stylix for bat outputs a theme that this can use
                        syntax-theme =
                            lib.mkIf (config.my.stylix.enabled && (config.stylix.targets.bat.enable or false))
                            "base16-stylix";
                        plus-style = "syntax auto";
                        minus-style = "syntax auto";
                    };
                }
                // lib.optionalAttrs (cfg.pager == "diffnav") {
                    file-style = "omit";
                    file-decoration-style = "none";
                    hunk-label = "  󰡏 ";
                    line-numbers = true;
                };

            home.packages = lib.mkIf (cfg.pager == "diffnav") [pkgs.diffnav];

            home.shellAliases = {
                ga = "git add";
                gc = "git commit";
                gap = "git add --patch";
                gs = "git status";
                gl = "git log --all --graph --pretty=format:'%C(magenta)%h %C(white) %an  %ar%C(blue)  %D%n%s%n'";
                glb = "git log --first-parent --graph --pretty=format:'%C(magenta)%h %C(white) %an  %ar%C(blue)  %D%n%s%n'";
                gd = "git diff --output-indicator-new=' '  --output-indicator-old=' '";
                gch = "git checkout";
            };
        };
    };
}
