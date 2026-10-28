{
    self,
    inputs,
    ...
}: {
    flake.modules.nixos.sirius-james = {pkgs, ...}: {
        imports = with self.modules.nixos; [
            inputs.home-manager.nixosModules.home-manager
            james
            home-manager-interface

            sops

            # desktop shell
            hyprland

            # gaming

            steam
            gamemode
            gamescope
            wivrn

            # tools
            docker
            wireshark
            micro-controller
            ollama
            searx
            # pia-openvpn
        ];
        config = {
            my.home-manager.enabled = true;
            home-manager.useUserPackages = true;
            home-manager.useGlobalPkgs = true;
            home-manager.extraSpecialArgs = {
                # inherit system;
                inherit inputs;
                inherit pkgs; # makes sure to inherit overlays like nixLoki
            };
            home-manager.users.james.imports = [
                self.modules.homeManager.sirius-james
            ];
            my = {
                services.docker.groupUsers = ["james"];
                gaming.gamemode.users = ["james"];
                cli-tools.micro-controller.udevGroupMembers = ["james"];
                gui-apps.wireshark.users = ["james"];
                allowedUnfreePkgNames = [
                    "spotify"
                    "slack"
                    "obsidian"
                    "firefox"
                ];
                services.ollama.models = [
                    # "qwen3.6:27b-coding"
                    # "qwen3:14b"
                    "gpt-oss:20b"
                ];
            };
        };
    };
    flake.modules.homeManager.sirius-james = {pkgs, ...}: {
        imports = with self.modules.homeManager; [
            james-full

            sops
            stylix

            # CLI
            gh-cli
            nix-index
            pi
            btop

            # SERVICES
            mcp

            # GUI
            obsidian
            libresuite
            jellyfin-desktop

            # GAMING
            proton
            lutris
            mangohud
            wivrn
        ];
        config = {
            home.stateVersion = "25.05"; # Please read the comment before changing.
            home.packages = with pkgs; [
                # CLI
                cloc
                gzip
                nmap
                hwinfo
                # usbutils
                lshw
                # snakeviz
                # ngrok
                # rlwrap
                # android-tools
                # mycli

                # GUI
                vlc
                drawio
                # zotero
                freetube
                slack
                vesktop
                spotify

                # GAMING
                prismlauncher
                heroic
                protonplus
            ];

            my = {
                cli-tools.nixLoki.pi-executable = "pi-writeable";
                services.mcp.allowedServers = ["searx"];
                desktop = {
                    hyprland = {
                        monitors = [
                            {
                                output = "desc:Acer";
                                position = "auto-right";
                            }
                            {
                                output = "desc:Lenovo";
                                position = "auto-left";
                            }
                        ];
                        workspaces = [
                            {
                                workspace = "1";
                                rules = {
                                    monitor = "desc:Lenovo";
                                    default = true;
                                };
                            }
                            {
                                workspace = "2";
                                rules = {
                                    monitor = "desc:Acer";
                                    default = true;
                                };
                            }
                            {
                                workspace = "3";
                                rules = {
                                    monitor = "desc:Lenovo";
                                    default = true;
                                };
                            }
                            {
                                workspace = "4";
                                rules = {
                                    monitor = "desc:Acer";
                                    default = true;
                                };
                            }
                        ];
                    };
                };
            };
        };
    };
}
