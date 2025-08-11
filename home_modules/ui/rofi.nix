{
    pkgs,
    lib,
    config,
    ...
}:
let
    inherit (lib) mkIf mkEnableOption;
in
{
    options = {
        ui.rofi.enable = mkEnableOption {
            default = false;
            description = "Enable rofi config";
        };
    };
    config = mkIf config.ui.rofi.enable {
        programs.rofi = {
            enable = true;
            package = pkgs.rofi-wayland;
            # configPath =
            cycle = true; # cycle through results
            extraConfig = {
                show-icons = true;
                terminal = "wezterm";
                drun-display-format = "{icon} {name}";
                location = 0;
                disable-history = false;
                hide-scrollbar = true;
                display-drun = " 󰀻  Apps ";
                display-run = "   Run ";
                display-window = " 󰕰  Window";
                display-ssh = "   SSH";
                display-keys = " 󰯄  Keys";
                sidebar-mode = true;
                fixed-num-lines = true; # number of lines in picker is always the same
            };
            location = "center";
            modes = [
                "drun"
                "window"
                "keys"
                "ssh"
            ];
            plugins = [ pkgs.keepmenu ]; # keepass rofi plugin
            # terminal =  # path to terminal to be used to run terminal cmds
            # layout stuff, stylix does colours
            theme =
                let
                    inherit (config.lib.formats.rasi) mkLiteral;
                    inherit (config.lib.stylix) colors;
                    # using the method used in the stylix rofi config to change
                    # base16 colors into rgba literals. Cant seem to get opacity
                    # settings so i'm just setting it to 100.
                    mkRgba =
                        opacityLiteral: color:
                        let
                            c = colors;
                            r = c."${color}-rgb-r";
                            g = c."${color}-rgb-g";
                            b = c."${color}-rgb-b";
                        in
                        mkLiteral "rgba ( ${r}, ${g}, ${b}, ${opacityLiteral} % )";
                    rofiOpacity = "100"; # wouldn't want anything other than 100% here anyway
                    mauve = mkRgba rofiOpacity "base0E";
                in
                {
                    window.height = mkLiteral "40%";
                    window.width = mkLiteral "40%";
                    listview = {
                        columns = 1;
                        lines = 10;
                        margin = mkLiteral "2% 0%";
                    };
                    # overriding some colors here because stylix chooses bad ones
                    "element selected.normal".background-color = lib.mkForce mauve;
                    "button selected".background-color = lib.mkForce mauve;

                };
            # xoffset = ;
            # yoffset = ;
        };
        stylix.targets.rofi.enable = true;
    };
}
