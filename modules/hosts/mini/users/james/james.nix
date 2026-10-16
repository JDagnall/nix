{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.mini.james = {
        pkgs,
        config,
        ...
    }: {
        # TODO: should be importing some version of my user config
        imports = with self.modules.nixos; [];
        config = {
        };
    };
}
