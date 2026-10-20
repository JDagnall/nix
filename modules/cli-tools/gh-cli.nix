{self, ...}: {
    flake.modules.homeManager.gh-cli = {config, ...}: {
        imports = with self.modules.homeManager; [git];
        config = {
            programs.gh = {
                enable = true;
                settings = {
                    aliases = {};
                    editor = config.home.sessionVariables.EDITOR;
                    git_protocol = "ssh";
                    pager = config.my.cli-tools.git.pager;
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
                        diff = config.my.cli-tools.git.pager;
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
        };
    };
}
