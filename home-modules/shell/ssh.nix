{
    lib,
    config,
    osConfig,
    ...
}: {
    options = {
        shell.ssh.enable = lib.mkEnableOption "Enable ssh user config.";
    };
    config = lib.mkIf config.shell.ssh.enable {
        programs.ssh = {
            enable = true;
            enableDefaultConfig = false;
            # can only reliably resolve these hosts is with tailscale
            settings = lib.mkIf osConfig.service.tailscale.enable {
                "Host mini" = {
                    HostName = "mini";
                    User = "james";
                    IdentityFile = "~/.ssh/key";
                };
                "Host framework" = {
                    HostName = "framework";
                    User = "james";
                    IdentityFile = "~/.ssh/key";
                };
                "Host pc" = {
                    HostName = "pc";
                    User = "james";
                    IdentityFile = "~/.ssh/key";
                };
                "Host book" = {
                    HostName = "book";
                    User = "james";
                    IdentityFile = "~/.ssh/key";
                };
                "Host orion" = {
                    HostName = "orion";
                    User = "james";
                    IdentityFile = "~/.ssh/key";
                };
            };
        };
    };
}
