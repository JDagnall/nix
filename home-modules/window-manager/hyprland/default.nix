{
    pkgs,
    lib,
    config,
    inputs,
    osConfig,
    ...
}: let
    inherit
        (lib)
        mkIf
        mkEnableOption
        mkOption
        mkOrder
        mkMerge
        types
        ;
in {
    options = {
        window-manager.hyprland = {
            enable = mkEnableOption "Enable Hyprland config";
            monitors = mkOption {
                default = [", preferred, auto, 1"];
                type = types.listOf types.str;
                description = ''
                    The device specific monitor config to be added to the hyprland config.
                    Generally just defines the monitors and their positions'';
            };
            workspaces = mkOption {
                default = [];
                type = types.listOf types.str;
                description = ''
                    The device specific workspace config to be added to the hyprland config.
                    Generally just defines which workspaces to bind to which monitor.'';
            };
            enableTouchpadSwipe = mkEnableOption "Enable touchpad swiping for workspaces";
            enableHyprPolkit = mkOption {
                type = types.bool;
                default = true;
                description = "Enable hyprpolkit agent, for privellige escalation";
            };
        };
    };
    config = mkIf config.window-manager.hyprland.enable {
        home.packages = with pkgs; [
            wl-clipboard # clipboard
            wtype # autotype
        ];
        services.hyprpolkitagent.enable = config.window-manager.hyprland.enableHyprPolkit;
        wayland.windowManager.hyprland = {
            enable = true;
            configType = "hyprlang";
            package = null;
            portalPackage = null;
            # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
            # portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
            systemd = {
                enable = true;
                # extraCommands = [];
                # enableXdgAutostart = true;
                # variables = [];
            };
            # importantPrefixes = [];
            # portalPackage = ;
            xwayland.enable = true;
            # plugins = [ ];
            sourceFirst = true;
            settings = let
                inherit (lib) optionals;
                inherit (config.ui) swayosd;
                inherit (osConfig.services) pipewire;
                inherit
                    (config.tools)
                    brightnessctl
                    playerctl
                    ;
            in {
                "$mod" = "SUPER";
                bindel = let
                    swayosd-bin = "${pkgs.swayosd}/bin/swayosd-client";
                    brightnessctl-bin = "${pkgs.brightnessctl}/bin/brightnessctl";
                    wpctl-bin = "${pkgs.wireplumber}/bin/wpctl";
                in
                    []
                    ++ optionals (swayosd.enable && brightnessctl.enable)
                    [
                        ",XF86MonBrightnessDown, exec, ${swayosd-bin} --brightness lower"
                        ",XF86MonBrightnessUp, exec, ${swayosd-bin} --brightness raise"
                    ]
                    ++ optionals (brightnessctl.enable && !swayosd.enable)
                    [
                        ",XF86MonBrightnessUp, exec, ${brightnessctl-bin} -e4 -n2 set 5%+"
                        ",XF86MonBrightnessDown, exec, ${brightnessctl-bin} -e4 -n2 set 5%-"
                    ]
                    ++ optionals brightnessctl.enable
                    [
                        ",XF86KbdBrightnessUp, exec, ${brightnessctl-bin} --device=smc::kbd_backlight s 10%+"
                        ",XF86KbdBrightnessDown, exec, ${brightnessctl-bin} --device=smc::kbd_backlight s 10%-"
                    ]
                    ++ optionals (swayosd.enable && pipewire.enable)
                    [
                        ",XF86AudioRaiseVolume, exec, ${swayosd-bin} --output-volume raise"
                        ",XF86AudioLowerVolume, exec, ${swayosd-bin} --output-volume lower"
                        ",XF86AudioMute, exec, ${swayosd-bin} --output-volume mute-toggle"
                        ",XF86AudioMicMute, exec, ${swayosd-bin} --input-volume mute-toggle"
                    ]
                    ++ optionals (pipewire.enable && !swayosd.enable)
                    [
                        ",XF86AudioRaiseVolume, exec, ${wpctl-bin} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
                        ",XF86AudioLowerVolume, exec, ${wpctl-bin} set-volume @DEFAULT_AUDIO_SINK@ 5%-"
                        ",XF86AudioMute, exec, ${wpctl-bin} set-mute @DEFAULT_AUDIO_SINK@ toggle"
                        ",XF86AudioMicMute, exec, ${wpctl-bin} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
                    ];

                bindl = let
                    playerctl-bin = "${pkgs.playerctl}/bin/playerctl";
                in
                    []
                    ++ (
                        if playerctl.enable
                        then [
                            ",XF86AudioNext, exec, ${playerctl-bin} next"
                            ",XF86AudioPause, exec, ${playerctl-bin} play-pause"
                            ",XF86AudioPlay, exec, ${playerctl-bin} play-pause"
                            ",XF86AudioPrev, exec, ${playerctl-bin} previous"
                        ]
                        else []
                    );
                bind = [] ++ optionals config.tools.keepmenu.enable ["$mod, a, exec, ${pkgs.keepmenu}/bin/keepmenu"];
                monitor = config.window-manager.hyprland.monitors;
                workspace = config.window-manager.hyprland.workspaces;
                gesture = [] ++ optionals config.window-manager.hyprland.enableTouchpadSwipe ["3,horizontal,workspace"];
            };
            extraConfig = let
                configFile = builtins.readFile ./hyprland.conf;
                autostarts = ''
                    #################
                    ### AUTOSTART ###
                    #################
                    ${
                        if config.ui.waybar.autostart
                        then "exec-once = pidof waybar || ${pkgs.waybar}/bin/waybar &"
                        else ""
                    }
                                      ${
                        if config.ui.noctalia.enable
                        # have to use the package from the input to have it
                        # match the one that will be loaded into the environment
                        # otherwise ipc calls will not work if its not the same executable
                        then "exec-once = ${inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/noctalia-shell &"
                        else ""
                    }
                    ${
                        if config.ui.syncthingtray.autostart
                        then "exec-once = ${pkgs.syncthingtray}/bin/syncthingtray --wait &"
                        else ""
                    }
                    ${
                        if config.tools.keepassxc.autostart
                        then "exec-once = ${pkgs.keepassxc}/bin/keepassxc --minimized &"
                        else ""
                    }
                '';
                variables = ''
                    #################
                    ### VARIABLES ###
                    #################
                    # $mod = SUPER # sets "Windows" key as the main mod key
                    # there is no alternative for either of these at the moment so they have to be set
                    ${
                        if config.ui.rofi.launcherShortcut
                        then "$menu = ${pkgs.rofi}/bin/rofi -show drun"
                        else if config.ui.noctalia.launcherShortcut
                        # have to use the package from the input to have it
                        # match the one that will be loaded into the environment
                        # otherwise ipc calls will not work if its not the same executable
                        then "$menu = ${inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/noctalia-shell ipc call launcher toggle"
                        else ""
                    }
                    ${
                        if (config.home.sessionVariables ? TERMINAL)
                        then "$terminal = ${config.home.sessionVariables.TERMINAL}"
                        else "$terminal = ${pkgs.wezterm}/bin/wezterm"
                    }
                '';
                orderedConfigFile = mkOrder 500 configFile;
                orderedVariables = mkOrder 250 variables;
                orderedAutostarts = mkOrder 1000 autostarts;
                merged = mkMerge [
                    orderedVariables
                    orderedConfigFile
                    orderedAutostarts
                ];
            in
                merged;
        };
        stylix.targets.hyprland = mkIf config.stylix.enableHomeConfig {
            enable = true;
            colors.enable = true;
        };
    };
}
