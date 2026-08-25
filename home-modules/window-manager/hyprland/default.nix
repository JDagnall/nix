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
        types
        ;
in {
    options = {
        window-manager.hyprland = {
            enable = mkEnableOption "Enable Hyprland config";
            monitors = mkOption {
                default = [];
                type = types.listOf (types.submodule {
                    options = {
                        output = mkOption {
                            type = types.str;
                            description = "Display output specification as per hyprland specification.";
                        };
                        mode = mkOption {
                            type = types.str;
                            default = "preferred";
                            description = "Display output mode as per hyprland specification.";
                        };
                        position = mkOption {
                            default = "auto";
                            type = types.str;
                            description = "Position for the monitor as per hyprland specification.";
                        };
                        scale = mkOption {
                            type = types.int;
                            description = "The scale factor for the monitor";
                            default = 1;
                        };
                    };
                });
                description = ''
                    The device specific monitor config to be added to the hyprland config.
                    Generally just defines the monitors and their positions'';
            };
            workspaces = mkOption {
                default = [];
                type = types.listOf (types.submodule {
                    options = {
                        workspace = mkOption {
                            type = types.str;
                            description = "Workspace number/name as per hyprland specification.";
                        };
                        rules = mkOption {
                            type = types.attrsOf (types.oneOf [types.int types.str]);
                        };
                    };
                });
                description = ''
                    The device specific workspace config to be added to the hyprland config.
                    Generally just defines which workspaces to bind to which monitor.'';
            };
            enableTouchpadSwipe = mkEnableOption "Enable touchpad swiping for workspaces";
            enableHyprPolkit = mkEnableOption "Enable hyprpolkit agent, for privellige escalation";
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
            configType = "lua";
            package = null;
            portalPackage = null;
            # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
            # portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
            systemd = {
                enable = !(osConfig.programs.hyprland.withUWSM);
                # extraCommands = [];
                # enableXdgAutostart = true;
                # variables = [];
            };
            extraLuaFiles = {
                main = {
                    autoLoad = true;
                    content = builtins.readFile ./main.lua;
                };
            };
            # importantPrefixes = [];
            # portalPackage = ;
            xwayland.enable = true;
            # plugins = [ ];
            sourceFirst = true;
            settings = let
                inherit (lib) optionals;
                luaInline = lib.generators.mkLuaInline;
                inherit (osConfig.services) pipewire;
            in {
                bind = let
                    inherit
                        (config.tools)
                        brightnessctl
                        playerctl
                        ;
                    brightnessctl-bin = "${pkgs.brightnessctl}/bin/brightnessctl";
                    wpctl-bin = "${pkgs.wireplumber}/bin/wpctl";
                    playerctl-bin = "${pkgs.playerctl}/bin/playerctl";
                    mod_key = "SUPER";
                    # flags for the binds
                    el_bind_flags = {
                        locked = true;
                        repeating = true;
                    };
                    l_bind_flags = {
                        locked = true;
                    };
                    mkBind = bind: action: flags: {
                        _args = [
                            (luaInline "\"${bind}\"")
                            (luaInline "hl.dsp.exec_cmd(\"${action}\")")
                            flags
                        ];
                    };
                    # the order of these does not follow any logic, they just shouldnt be enabled at the same time
                    terminal =
                        if (config.home.sessionVariables ? TERMINAL)
                        then config.home.sessionVariables.TERMINAL
                        else "${pkgs.wezterm}/bin/wezterm";
                    launcherCmd =
                        if config.ui.noctalia.launcherShortcut
                        # have to use the package from the input to have it
                        # match the one that will be loaded into the environment
                        # otherwise ipc calls will not work if its not the same executable
                        then "${inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/noctalia msg panel-toggle launcher"
                        else if config.ui.rofi.launcherShortcut
                        then "${pkgs.rofi}/bin/rofi -show drun"
                        else "";
                in
                    [
                        (mkBind "${mod_key} + t" "${terminal}" {})
                    ]
                    ++ optionals (launcherCmd != "") [
                        (mkBind "${mod_key} + d" "${launcherCmd}" {})
                    ]
                    ++ optionals brightnessctl.enable
                    [
                        (mkBind "XF86MonBrightnessUp" "${brightnessctl-bin} -e4 -n2 set 5%+" el_bind_flags)
                        (mkBind "XF86MonBrightnessDown" "${brightnessctl-bin} -e4 -n2 set 5%-" el_bind_flags)
                        (mkBind "XF86KbdBrightnessUp" "${brightnessctl-bin} --device=smc::kbd_backlight s 10%+" el_bind_flags)
                        (mkBind "XF86KbdBrightnessDown" "${brightnessctl-bin} --device=smc::kbd_backlight s 10%-" el_bind_flags)
                    ]
                    ++ optionals pipewire.enable
                    [
                        (mkBind "XF86AudioRaiseVolume" "${wpctl-bin} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+" el_bind_flags)
                        (mkBind "XF86AudioLowerVolume" "${wpctl-bin} set-volume @DEFAULT_AUDIO_SINK@ 5%-" el_bind_flags)
                        (mkBind "XF86AudioMute" "${wpctl-bin} set-mute @DEFAULT_AUDIO_SINK@ toggle" el_bind_flags)
                        (mkBind "XF86AudioMicMute" "${wpctl-bin} set-mute @DEFAULT_AUDIO_SOURCE@ toggle" el_bind_flags)
                    ]
                    ++ optionals config.tools.keepmenu.enable [
                        (mkBind "${mod_key} + a" "${pkgs.keepmenu}/bin/keepmenu" {})
                    ]
                    ++ lib.optionals playerctl.enable [
                        (mkBind "XF86AudioNext" "${playerctl-bin} next" l_bind_flags)
                        (mkBind "XF86AudioPause" "${playerctl-bin} play-pause" l_bind_flags)
                        (mkBind "XF86AudioPlay" "${playerctl-bin} play-pause" l_bind_flags)
                        (mkBind "XF86AudioPrev" "${playerctl-bin} previous" l_bind_flags)
                    ];
                # these are event callbacks, the hl.on() function, can be used for autostarts
                on = let
                    mkAutostart = cmd: {_args = [(luaInline "\"hyprland.start\"") (luaInline "function () hl.exec_cmd(\"${cmd}\") end")];};
                in
                    lib.optionals config.ui.waybar.autostart [(mkAutostart "pidof waybar || ${pkgs.waybar}/bin/waybar &")]
                    # have to use the package from the input to have it
                    # match the one that will be loaded into the environment
                    # otherwise ipc calls will not work if its not the same executable
                    ++ lib.optionals (config.ui.noctalia.enable && config.ui.noctalia.autostart.enable) [(mkAutostart "${inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/noctalia &")]
                    ++ lib.optionals config.ui.syncthingtray.autostart [(mkAutostart "${pkgs.syncthingtray}/bin/syncthingtray --wait &")]
                    ++ lib.optionals config.tools.keepassxc.autostart [(mkAutostart "${pkgs.keepassxc}/bin/keepassxc --minimized &")];
                monitor = let
                    mkMonitor = monitor: {_args = monitor;};
                in
                    map mkMonitor config.window-manager.hyprland.monitors;
                workspace = let
                    mkWorkspace = workspace: {
                        _args = [({workspace = workspace.workspace;} // workspace.rules)];
                    };
                in
                    map mkWorkspace config.window-manager.hyprland.workspaces;
                gesture =
                    []
                    ++ optionals config.window-manager.hyprland.enableTouchpadSwipe [
                        {
                            _args = [
                                {
                                    fingers = 3;
                                    direction = "horizontal";
                                    action = "workspace";
                                }
                            ];
                        }
                    ];
            };
        };
        stylix.targets.hyprland = mkIf config.stylix.enableHomeConfig {
            enable = true;
            colors.enable = true;
        };
    };
}
