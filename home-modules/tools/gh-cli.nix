{
    pkgs,
    lib,
    config,
    ...
}:
{
    options = {
        tools.gh-cli.enable = lib.mkEnableOption {
            default = "Enable github cli config, include gh-dash dashboard.";
        };
    };
    config = lib.mkIf config.tools.gh-cli.enable {
        programs.gh = {
            enable = true;
            settings = {
                aliases = { };
                editor = config.home.sessionVariables.EDITOR;
                git_protocol = "ssh";
                pager =
                    if config.tools.git.pager == "diff-so-fancy" then
                        "diff-so-fancy | less --quit-if-one-screen"
                    else
                        config.tools.git.pager; # return just the name of the set pager
            };
            extensions = [ ];
            gitCredentialHelper = {
                enable = true;
                # hosts = {};
            };
        };
        programs.gh-dash = {
            enable = true;
            settings = {
                pager =
                    if config.tools.git.pager == "diff-so-fancy" then
                        "diff-so-fancy | less --quit-if-one-screen"
                    else
                        config.tools.git.pager; # return just the name of the set pager
                preview = {
                    open = true;
                    width = 80;
                };
                prSections = [
                    {
                        title = "mine";
                        filters = "is:open author:@me";
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
                        filters = "is:open repo:touramigo/zeus";
                        layout = {
                            author = {
                                hidden = false;
                            };
                            repoName = {
                                hidden = true;
                            };
                        };

                    }
                ];
            };
        };
    };
}
