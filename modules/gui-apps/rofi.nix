{
    self,
    lib,
    ...
}: {
    flake.modules.homeManager.rofi = {config, ...}: {
        imports = with self.modules.homeManager; [stylix-interface];
        config = {
            programs.rofi = {
                enable = true;
                settings = {
                    cycle = true; # cycle through results
                    location = 1;
                    modes = [
                        "drun"
                        "window"
                        "ssh"
                    ];
                    show-icons = true;
                    terminal = lib.mkIf (config.home.sessionVariables ? TERMINAL) config.home.sessionVariables.TERMINAL;
                    drun-display-format = "{icon} {name}";
                    disable-history = false;
                    hide-scrollbar = true;
                    display-drun = " 󰀻  Apps ";
                    display-run = "   Run ";
                    display-window = " 󰕰  Window";
                    display-ssh = "   SSH";
                    sidebar-mode = true;
                    fixed-num-lines = true; # number of lines in picker is always the same
                    kb-secondary-copy = ""; # was previously <C-c>
                    kb-cancel = "Control+c,Escape"; # exit rofi with <C-c>
                    matching = "fuzzy"; # fuzzy search
                    sort = true; # sorts in order of fuzzy match
                    sorting-method = "fzf";
                };
                # terminal =  # path to terminal to be used to run terminal cmds

                # layout stuff, stylix does colours
                theme = let
                    inherit (config.lib.formats.rasi) mkLiteral;
                    inherit (config.lib.stylix) colors;
                    inherit (config.stylix) opacity;
                    # using the method used in the stylix rofi config to change
                    # base16 colors into rgba literals.
                    mkRgba = opacityString: color: let
                        c = colors;
                        r = c."${color}-rgb-r";
                        g = c."${color}-rgb-g";
                        b = c."${color}-rgb-b";
                    in
                        mkLiteral "rgba ( ${r}, ${g}, ${b}, ${opacityString} % )";
                    rofiOpacity = toString (builtins.ceil (opacity.popups * 100));
                    purple = mkRgba rofiOpacity "base0E"; # in most colour schemes
                in
                    {
                        window.height = mkLiteral "40%";
                        window.width = mkLiteral "40%";
                        listview = {
                            columns = 1;
                            lines = 10;
                        };
                        element.padding = mkLiteral "10px";
                    }
                    // lib.optionalAttrs config.my.stylix.enabled {
                        "element selected.normal".background-color = lib.mkForce purple;
                        "button selected".background-color = lib.mkForce purple;
                    };

                # xoffset = ;
                # yoffset = ;
            };
            stylix.targets.rofi.enable = config.my.stylix.enabled;
        };
    };
}
