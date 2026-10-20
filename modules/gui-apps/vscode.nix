{
    self,
    lib,
    ...
}: {
    flake.modules.homeManager.vscode = {
        pkgs,
        config,
        ...
    }: {
        imports = with self.modules.homeManager; [stylix-interface];
        config = {
            programs.vscode = {
                enable = true;
                # whether extensions can be updated and installed imperitively
                mutableExtensionsDir = false;
                profiles."default" = {
                    enableExtensionUpdateCheck = false;
                    enableUpdateCheck = false;
                    extensions = with pkgs.vscode-extensions; [
                        github.vscode-pull-request-github
                        vscodevim.vim
                        christian-kohler.path-intellisense
                        esbenp.prettier-vscode
                        redhat.vscode-xml
                        redhat.vscode-yaml
                        redhat.java
                        tomoki1207.pdf
                        charliermarsh.ruff
                        ms-python.python
                        ms-vscode.cpptools
                    ];
                    userSettings = {};
                    keybindings = [];
                    languageSnippets = {};
                    globalSnippets = {};
                };
            };
            stylix.targets.vscode = lib.mkIf config.my.stylix.enabled {
                enable = true;
                profileNames = ["default"];
            };
        };
    };
}
