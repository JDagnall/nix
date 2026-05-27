{
    pkgs,
    lib,
    config,
    ...
}: {
    options = {
        tools.gh-cli.enable = lib.mkEnableOption {
            default = "Enable github cli config, include gh-dash dashboard.";
        };
        tools.gh-cli.diffnav.enable = lib.mkOption {
            default = true;
            type = lib.types.bool;
            description = "Use diffnav for diffs, relies on delta config. defaults to true.";
        };
    };
    config = lib.mkIf config.tools.gh-cli.enable {
        assertions = [
            {
                assertion = config.tools.git.enable;
                message = "Git is required for the github cli, please enable it or disable this";
            }
        ];
        programs.gh = {
            enable = true;
            settings = {
                aliases = {};
                editor = config.home.sessionVariables.EDITOR;
                git_protocol = "ssh";
                pager =
                    if config.tools.git.pager == "diff-so-fancy"
                    then "diff-so-fancy | less --quit-if-one-screen"
                    else if config.tools.git.pager == "delta" && config.tools.gh-cli.diffnav.enable
                    then "diffnav"
                    else config.tools.git.pager; # return just the name of the set pager
            };
            extensions = [];
            gitCredentialHelper = {
                enable = true;
                # hosts = {};
            };
        };
        programs.gh-dash = {
            enable = true;
            settings = {
                pager = {
                    diff =
                        if config.tools.git.pager == "diff-so-fancy"
                        then "diff-so-fancy | less --quit-if-one-screen"
                        else if config.tools.git.pager == "delta" && config.tools.gh-cli.diffnav.enable
                        then "diffnav"
                        else config.tools.git.pager; # return just the name of the set pager
                };
                defaults = {
                    preview = {
                        open = true;
                        width = 80;
                    };
                };
                prSections = [
                    {
                        title = "Mine";
                        filters = "is:open author:@me sort:updated-desc";
                        layout = {
                            author = {
                                hidden = true;
                            };
                            repoName = {
                                hidden = false;
                            };
                        };
                    }
                    {
                        title = "TA zeus";
                        filters = "is:open repo:touramigo/zeus sort:updated-desc";
                        layout = {
                            author = {
                                hidden = false;
                            };
                            repoName = {
                                hidden = true;
                            };
                        };
                    }
                    {
                        title = "Involved";
                        filters = "is:open sort:updated-desc involves:@me";
                        layout = {
                            author = {
                                hidden = false;
                            };
                            repoName = {
                                hidden = false;
                            };
                        };
                    }
                ];
            };
        };
        home.packages = [] ++ lib.optionals config.tools.gh-cli.diffnav.enable [pkgs.diffnav];
    };
}
