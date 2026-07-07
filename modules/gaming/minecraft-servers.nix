{
    pkgs,
    lib,
    config,
    inputs,
    ...
}: {
    imports = [
        inputs.nix-minecraft.nixosModules.minecraft-servers
        {
            nixpkgs.overlays = [inputs.nix-minecraft.overlay];
        }
    ];
    options = {
        gaming.minecraft-servers = {
            enable = lib.mkEnableOption "Enable minecraft servers configuration";
            groupMembers = lib.mkOption {
                type = with lib.types; listOf str;
                default = [];
                description = "Users to add to the 'minecraft' group.";
            };
            "26.2" = lib.mkEnableOption "Enable 26.2 server";
        };
    };

    config = lib.mkIf config.gaming.minecraft-servers.enable {
        allowedUnfreePkgNames = ["minecraft-server"];
        users.groups."minecraft".members = config.gaming.minecraft-servers.groupMembers;

        services.minecraft-servers = let
            defaultServerConfig = {
                restart = "no";
                enableReload = true;
                jvmOpts = "-Xmx2G -Xms1G";
                serverProperties = {
                    server-port = 26595;
                    enable-rcon = false;
                    enforce-whitelist = true;
                    white-list = true;
                };
            };
        in {
            enable = true;
            eula = true;
            managementSystem = {
                tmux.enable = false;
                systemd-socket.enable = true;
            };

            # the defaults
            dataDir = "/srv/minecraft";
            user = "minecraft";
            group = "minecraft";

            servers = {
                "26.2" =
                    defaultServerConfig
                    // {
                        enable = config.gaming.minecraft-servers."26.2";
                        package = pkgs.fabricServers.fabric-26_2.override (old: {
                            jre_headless = lib.warnIf (
                                lib.versions.major old.jre_headless.version == "25"
                            ) "nix-minecraft is using Java 25, override is now redundant"
                            pkgs.openjdk25_headless;
                        });
                        openFirewall = true;
                        symlinks = {
                            # "mods" = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
                            #     servux = pkgs.fetchurl {
                            #         url = "https://cdn.modrinth.com/data/zQhsx8KF/versions/4NqOw9an/servux-fabric-1.21.10-0.8.3.jar";
                            #         sha256 = "1cyxys1g3s268frn5mjliahnh2ybhp4i0265himfa09p76wh5837";
                            #     };
                            #     carpet = pkgs.fetchurl {
                            #         url = "https://cdn.modrinth.com/data/TQTTVgYE/versions/aVB2lYQQ/fabric-carpet-1.21.4-1.4.161%2Bv241203.jar";
                            #         hash = "sha256-AxFO/ZnFl6Y4ZD2OuXt9xIUxjAB3UHddil6MhmtE7XY=";
                            #         name = "fabric-carpet-1.21.4.jar";
                            #     };
                            # });
                        };
                    };
            };
        };
    };
}
