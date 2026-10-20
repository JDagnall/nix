{
    self,
    lib,
    inputs,
    ...
}: {
    flake.modules.homeManager.nixLoki = {
        pkgs,
        config,
        ...
    }: {
        options = {
            my.cli-tools.nixLoki = {
                theme = lib.mkOption {
                    default = "catppuccin";
                    type = lib.types.enum ["catppuccin" "mini-base16" "tinted-nvim"];
                    description = "The plugin to style nvim with, mini-base16 and tinted-nvim use stylix.";
                };
                enableWezterm = lib.mkOption {
                    # default = config.programs.wezterm.enable;
                    # https://github.com/willothy/wezterm.nvim/issues/28
                    default = false;
                    type = lib.types.bool;
                    description = "Enable the wezterm integration";
                };
            };
        };
        # required for the home manager modules exported by nixLoki to be available in the namespace
        imports = with self.modules.homeManager; [inputs.nixLoki.homeModule stylix-interface];
        config = let
            cfg = config.my.cli-tools.nixLoki;
        in {
            assertions = [
                {
                    assertion =
                        config.my.stylix.enabled
                        || (cfg.theme != "mini-base16" && cfg.theme != "tinted-nvim");
                    message = "Using mini-base16 or tinted-nvim with nixLoki requires stylix.";
                }
            ];
            programs.nixLoki = {
                enable = true;
                # nixLoki packages to install
                packageNames = ["nixLoki" "testNixLoki"];
                packageDefinitions = {
                    # this merges into the package config for nixLoki
                    merge = let
                        # the values being added to the nixLoki config to set the theme and provide base16 colours
                        merges = {...}: {
                            categories = {
                                "${cfg.theme}" = true;
                            };
                            extra =
                                # cant use mkIf here cause its evaluated wierdly by nixCats
                                if (cfg.theme == "mini-base16" || cfg.theme == "tinted-nvim")
                                then {
                                    # gets every stylix base16 colour into a set that lua will be able to digest in the nixLoki flake
                                    base16Colours = pkgs.lib.filterAttrs (k: v: (builtins.match "base0[0-9A-F]" k) != null) config.lib.stylix.colors.withHashtag;
                                }
                                else {};
                        };
                    in {
                        testNixLoki = merges;
                        nixLoki = merges;
                    };
                    replace = let
                        # the values being overrided in the nixLoki config
                        overrides = {...}: {
                            categories = {
                                wezterm = cfg.enableWezterm;
                            };
                        };
                    in {
                        testNixLoki = overrides;
                        nixLoki = overrides;
                    };
                };
            };
            home.sessionVariables = {EDITOR = "nixLoki";};
        };
    };
}
