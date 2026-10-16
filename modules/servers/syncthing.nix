{
    self,
    lib,
    inputs,
    ...
}: {
    flake.modules.nixos.syncthing.server = {
        pkgs,
        config,
        ...
    }: {
        imports = with self.modules.nixos; [sops syncthing];
        config = let
            serverCfg = config.my.servers.servers.syncthing;
        in {
            my.servers.servers.syncthing = {
                port = 8384;
                user = "syncthing";
                host = "localhost";
                openFirewall = false;
                mkRevProxy = true;
            };
            sops.secrets = let
                host = config.networking.hostName;
                secretSettings = {
                    sopsFile = "${inputs.secrets}/${host}/syncthing.yaml";
                    restartUnits = ["syncthing.service"];
                };
            in
                lib.mkIf config.sops.enable {
                    "syncthing/gui-password" = secretSettings;
                    "syncthing/hashed-gui-password" = secretSettings;
                    "syncthing/gui-username" = secretSettings;
                };
            services.syncthing = {
                guiAddress = lib.mkForce "${serverCfg.host}:${serverCfg.port}";
                # guiPasswordFile = config.sops.secrets."syncthing/password".path;
            };
            networking.firewall.allowedTCPPorts = lib.mkIf serverCfg.openFirewall [serverCfg.port];
            # this sets the syncthing gui password and user. There is a way to set the password
            # with the nixos options but seemingly not the username
            systemd.services.syncthing = {
                after = ["syncthing-loginmanager.service"];
                requires = ["syncthing-loginmanager.service"];
            };
            systemd.services.syncthing-loginmanager = {
                description = "Syncthing GUI Login Manager";
                # requisite = ["syncthing.service"];
                before = ["syncthing.service" "syncthing-init.service"];
                wantedBy = ["multi-user.target"];
                serviceConfig = {
                    User = config.services.syncthing.user;
                    RemainAfterExit = true;
                    # RuntimeDirectory = "syncthing-init";
                    Type = "oneshot";
                    ExecStart = pkgs.writers.writeBash "add-syncthing-gui-login"
                    ''
                        ${pkgs.syncthing}/bin/syncthing generate --gui-user=$(cat ${config.sops.secrets."gui-username"}) \
                        --gui-password=$(cat ${config.sops.secrets."syncthing/hashed-gui-password".path}) \
                        --home=${config.services.syncthing.configDir} || echo "Failed to set GUI login for syncthing."
                    '';
                };
            };
        };
    };
}
