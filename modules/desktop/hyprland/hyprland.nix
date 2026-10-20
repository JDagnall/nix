{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.hyprland = {
        pkgs,
        # config,
        ...
    }: let
    in {
        programs.hyprland = {
            enable = true;
            xwayland.enable = true;
            # UWSM improves systemd compatability stuff with wayland
            # make sure hyprland.systemd.enable is false, in home-manager or otherwise
            # as this will cause launching the session to crash
            withUWSM = true;
            # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
            # portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
        };
        programs.uwsm.enable = true;
        services.displayManager.defaultSession = "hyprland-uwsm"; # possibly unecesary, or should maybe be a separate option
        programs.uwsm.waylandCompositors = {
            hyprland = {
                prettyName = "Hyprland";
                comment = "Hyprland compositor managed by UWSM";
                binPath = "/run/current-system/sw/bin/start-hyprland";
            };
        };
        # cachix cache for hyprland package, so it doesn't have to be
        # rebuilt since we are pulling from the development branch
        nix.settings = {
            extra-substituters = ["https://hyprland.cachix.org"];
            extra-trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
        };

        environment.sessionVariables = {
            # if invisible cursor
            WLR_NO_HARDWARE_CURSORS = "1";
            # hint electron apps to use wayland
            NIXOS_OZONE_WL = "1";
        };

        environment.systemPackages = with pkgs; [
            wezterm # needed or could get stuck without a terminal
        ];

        # hardware = let
        #     # this is necesary because there will be a version mismatch
        #     # between hyprlands input pkgs and the global config packages
        #     # and apparently hyprland wants exact version matches with mesa
        #     hyprland-pkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
        # in {
        #     # Opengl
        #     graphics = {
        #         enable = true;
        #         package = hyprland-pkgs.mesa;
        #
        #         # enable 32 Bit, apparently good for steam
        #         enable32Bit = true;
        #         package32 = hyprland-pkgs.pkgsi686Linux.mesa;
        #     };
        # };

        # XDG portal
        xdg.portal.enable = true;
        xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };

    # TODO: need an interface pattern in nixos so that the home-manager module
    # can check if the nixos module is imported

    flake.modules.homeManager.hyprland = {
        pkgs,
        config,
        osConfig,
        ...
    }: {
        imports = with self.modules.homeManager; [desktop stylix-interface];
        options = {
            my.desktop.hyprland = {
                monitors = lib.mkOption {
                    default = [];
                    type = with lib.types;
                        listOf (submodule {
                            options = {
                                output = lib.mkOption {
                                    type = str;
                                    description = "Display output specification as per hyprland specification.";
                                };
                                mode = lib.mkOption {
                                    type = str;
                                    default = "preferred";
                                    description = "Display output mode as per hyprland specification.";
                                };
                                position = lib.mkOption {
                                    default = "auto";
                                    type = str;
                                    description = "Position for the monitor as per hyprland specification.";
                                };
                                scale = lib.mkOption {
                                    type = int;
                                    description = "The scale factor for the monitor";
                                    default = 1;
                                };
                            };
                        });
                    description = ''
                        The device specific monitor config to be added to the hyprland config.
                        Generally just defines the monitors and their positions'';
                };
                workspaces = lib.mkOption {
                    default = [];
                    type = with lib.types;
                        listOf (submodule {
                            options = {
                                workspace = lib.mkOption {
                                    type = str;
                                    description = "Workspace number/name as per hyprland specification.";
                                };
                                rules = lib.mkOption {
                                    type = attrsOf (oneOf [int str bool]);
                                };
                            };
                        });
                    description = ''
                        The device specific workspace config to be added to the hyprland config.
                        Generally just defines which workspaces to bind to which monitor.'';
                };
                binds = lib.mkOption {
                    default = [];
                    description = "List of binds, to add.";
                    type = with lib.types;
                        listOf (submodule {
                            options = {
                                bind = lib.mkOption {
                                    type = str;
                                    description = "String representation of the bind as per hyprland spec.";
                                };
                                flags = lib.mkOption {
                                    type = attrs;
                                    description = "Set passed to `hl.bind` as lua table";
                                    default = {};
                                };
                                action = lib.mkOption {
                                    type = str;
                                    description = "The action the bind takes, could be a command or lua expression.";
                                };
                                isCommand = lib.mkOption {
                                    type = bool;
                                    description = "Whether the action is a shell command or not.";
                                };
                            };
                        });
                };
                touchpadSwipe.enable = lib.mkEnableOption "Enable touchpad swiping for workspaces";
                hyprPolkit.enable = lib.mkEnableOption "Enable hyprpolkit agent, for privelige escalation";
            };
        };
        config = let
            cfg = config.my.desktop.hyprland;
            desktopCfg = config.my.desktop;
        in {
            my.desktop = {
                name = "hyprland";
                displayServer = "wayland";
                polkitProvider = lib.optionalString cfg.hyprPolkit.enable "hyprpolkitagent";
            };
            home.packages = with pkgs; [
                wl-clipboard # clipboard
                wtype # autotype
            ];
            services.hyprpolkitagent.enable = cfg.hyprPolkit.enable;
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
                in {
                    bind = let
                        mkBind = bind: {
                            _args = [
                                (luaInline "\"${bind.bind}\"")
                                (luaInline (
                                    if bind.isCommand
                                    then ''hl.dsp.exec_cmd("${bind.action}")''
                                    else bind.action
                                ))
                                bind.flags
                            ];
                        };
                    in
                        map mkBind cfg.binds;
                    # these are event callbacks, the hl.on() function, can be used for autostarts
                    on = let
                        mkAutostart = cmd: {_args = [(luaInline "\"hyprland.start\"") (luaInline "function () hl.exec_cmd(\"${cmd}\") end")];};
                    in
                        map mkAutostart desktopCfg.autostarts;
                    monitor = let
                        mkMonitor = monitor: {_args = [monitor];};
                    in
                        map mkMonitor cfg.monitors;
                    workspace_rule = let
                        mkWorkspace = workspace: {
                            _args = [({workspace = workspace.workspace;} // workspace.rules)];
                        };
                    in
                        map mkWorkspace cfg.workspaces;
                    # TODO: could have options for adding these, but I don't need this atm
                    gesture =
                        []
                        ++ optionals cfg.touchpadSwipe.enable [
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
            stylix.targets.hyprland = lib.mkIf config.my.stylix.enabled {
                enable = true;
                colors.enable = true;
            };
        };
    };
}
