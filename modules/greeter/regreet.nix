# had problems with this one crashing
{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.regreet = {
        pkgs,
        config,
        ...
    }: {
        imports = with self.modules.nixos; [stylix-interface];
        config = {
            services.greeter.regreet = {
                enable = true;
                settings = {};
            };
            # backend for regreet
            services.greetd = {
                enable = true;
                settings = {
                    # changing the backend compositor for regreet to a more modern one that
                    # can handle multiple monitors
                    default_session = {
                        command = let
                            swayCfg = pkgs.writeText "regreet-sway-cfg" ''
                                # output * scale 1 # dont scale
                                exec "${lib.getExe pkgs.regreet}; ${pkgs.sway}/bin/swaymsg exit"
                                include /etc/sway/config.d/* # I have no idea what this is needed for
                            '';
                        in "${lib.getExe pkgs.sway} --config ${swayCfg}";
                    };
                };
            };
            stylix.targets.regreet.enable = config.my.stylix.enabled;
        };
    };
}
