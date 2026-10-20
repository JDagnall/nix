{self, ...}: {
    flake.modules.homeManager.bat = {
        pkgs,
        config,
        ...
    }: {
        imports = with self.modules.homeManager; [stylix-interface];
        config = {
            programs.bat = {
                enable = true;
                extraPackages = with pkgs.bat-extras; [
                    batman
                    batdiff
                    batpipe
                    batgrep
                    prettybat
                ];
                # syntaxes = {}; extra  syntaxes
                # themes = { };
                config = {
                    style = "plain";
                    paging = "never";
                    color = "auto";
                };
            };
            home.shellAliases = {
                man = "batman --paging=always";
                cat = "bat";
            };
            stylix.targets.bat.enable = config.my.stylix.enabled;
        };
    };
}
