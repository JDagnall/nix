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
                display-drun = "   Apps ";
                display-run = "   Run ";
                display-window = " 󰕰  Window";
                display-network = " 󰤨  Network";
                display-ssh = "  ssh";
                sidebar-mode = true;
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
            # theme = {};
            # xoffset = ;
            # yoffset = ;
        };
        stylix.targets.rofi.enable = true;
    };
}
