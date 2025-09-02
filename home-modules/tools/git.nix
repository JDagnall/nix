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
        mkOption
        types
        ;
in
{
    options = {
        tools.git.enable = mkEnableOption {
            default = false;
            description = "enable git config";
        };
        tools.git.lfs.enable = mkEnableOption {
            default = false;
            description = "enable lfs and lfs config for git";
        };
        tools.git.pager = mkOption {
            type = types.enum [
                "delta"
                "diff-so-fancy"
                "diffnav"
            ];
            default = "delta";
        };
    };

    config =
        let
            inherit (config.tools.git) pager lfs;
        in
        mkIf config.tools.git.enable {
            programs.git =
                let
                    stylixColors = config.lib.stylix.colors.withHashtag;
                    deltaConfig = {
                        navigate = true;
                        diff-so-fancy = false; # emulate diff-so-fancy style
                        dark = true;
                        line-numbers = false;
                        side-by-side = false;
                        color-only = false; # no links etc, just highlighting
                        # stylix for bat outputs a theme that this can use
                        syntax-theme = if config.stylix.targets.bat.enable then "base16-stylix" else "gruvbox-dark";
                        plus-style = "syntax ${stylixColors.green}";
                        minus-style = "syntax ${stylixColors.red}";
                    };
                    diffnavDeltaConfig = {
                        file-style = "omit";
                        file-decoration-style = "none";
                        hunk-label = "  󰡏 ";
                        line-numbers = true;
                    };
                in
                {
                    enable = true;
                    attributes = [ ];
                    # options for diff viewer
                    diff-so-fancy = {
                        enable = if pager == "diff-so-fancy" then true else false;
                        changeHunkIndicators = true;
                        markEmptyLines = true;
                        pagerOpts = [ "--quit-if-one-screen" ];
                    };
                    # options for diff viewer (with syntax highlighting)
                    delta = {
                        enable = if pager == "delta" then true else false;
                        options = deltaConfig;
                    };

                    # hooks = {};
                    ignores = [
                        # Python
                        ".pytest_cache/"
                        "__pycache__/"
                    ];
                    lfs.enable = lfs.enable;
                    userName = "James Dagnall";
                    userEmail = "james.t.dagnall@gmail.com";
                    # translated to toml config files
                    extraConfig = {
                        core = {
                            editor = config.home.sessionVariables.EDITOR;
                            sshCommand = "ssh -i ~/.ssh/key";
                            whitespace = "error"; # threat trailing whitespace as error
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
                    }
                    # still want delta config if using diffnav
                    // (
                        if pager == "diffnav" then
                            {
                                delta = deltaConfig // diffnavDeltaConfig;
                                core = {
                                    pager = "${pkgs.diffnav}/bin/diffnav";
                                };
                            }
                        else
                            { }
                    );

                };

            home.packages = [ ] ++ (if config.tools.git.pager == "diffnav" then [ pkgs.diffnav ] else [ ]);

            programs.zsh.shellAliases = mkIf config.shell.zsh.enable {
                gap = "git add --patch";
                gs = "git status";
                gl = "git log --all --graph --pretty=format:'%C(magenta)%h %C(white) %an  %ar%C(blue)  %D%n%s%n'";
                glb = "git log --first-parent --graph --pretty=format:'%C(magenta)%h %C(white) %an  %ar%C(blue)  %D%n%s%n'";
                gd = "git diff --output-indicator-new=' '  --output-indicator-old=' '";
                gch = "git checkout";
            };
        };
}
