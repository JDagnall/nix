{self, ...}: {
    flake.modules.nixos.james = {pkgs, ...}: {
        users.groups.james = {};
        users.users.james = {
            isNormalUser = true;
            group = "james";
            extraGroups = ["wheel"];
            initialPassword = "pass";
            packages = with pkgs; [
                vim
                git
                zsh
                bash
            ];
            shell = pkgs.zsh;
        };
        # make sure we always have a shell
        programs.zsh.enable = true;
        # keyring
        services.gnome.gnome-keyring.enable = true;
        # will attempt to unlock keyring with users password on login
        security.pam.services.james.enableGnomeKeyring = true;
    };

    flake.modules.homeManager.james-headless = {pkgs, ...}: {
        imports = with self.modules.homeManager; [
            # CLI
            zsh
            bat
            eza
            fzf
            git
            nh
            nixLoki
            direnv
            zoxide
        ];
        config = {
            home.username = "james";
            home.homeDirectory = "/home/james";
            home.packages = with pkgs; [
                fd
                ripgrep
            ];
            my = {};
            # probably always going to keep this here
            programs.nh.osFlake = "/home/james/nix";

            programs.git.settings = {
                user = {
                    name = "James Dagnall";
                    email = "james.t.dagnall@gmail.com";
                };
            };
        };
    };

    flake.modules.homeManager.james-full = {pkgs, ...}: {
        imports = with self.modules.homeManager; [
            james-headless
            stylix

            # DESKTOP
            hyprland
            hypridle
            noctalia
            nm-applet
            bt-applet

            # GUI
            wezterm
            thunar
            imv
            firefox
            screencap-utils
            keepassxc
            keepmenu
        ];
        config = {
            home.packages = with pkgs; [
                # GUI
                pavucontrol
                seahorse
            ];
            my = {
                gui-apps = {
                    keepassxc.autostart = true;
                };
                desktop = {
                    noctalia = {
                        systemd.enable = true;
                        lockScreen.enable = true;
                        wallpaperProvider.enable = true;
                        notificationManager.enable = true;
                        osd.enable = true;
                        polkitProvider.enable = true;
                    };
                    hyprland = {
                        binds = [
                            {
                                bind = "SUPER + a";
                                action = "${pkgs.keepmenu}/bin/keepmenu";
                                isCommand = true;
                            }
                            {
                                bind = "SUPER + d";
                                action = "${pkgs.noctalia}/bin/noctalia msg panel-toggle launcher";
                                isCommand = true;
                            }
                        ];
                        # autostarts = [ ];
                    };
                };
                cli-tools.nixLoki.theme = "tinted-nvim";
            };
        };
    };
}
