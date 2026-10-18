{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.wsl-james = {
        pkgs,
        config,
        ...
    }: {
        # TODO: should be importing some version of my user config
        imports = with self.modules.nixos; [
        ];
        config = {
            my = {
                services.docker.groupUsers = ["james"];
            };
        };
    };
}
