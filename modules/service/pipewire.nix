{
    # pkgs,
    lib,
    config,
    ...
}: {
    options = {
        service.pipewire.enable = lib.mkEnableOption {description = "Enable pipewire audio server.";};
    };
    config = lib.mkIf config.service.pipewire.enable {
        services.pipewire = {
            enable = true;
            extraConfig = {
                pipewire = {};
                jack = {};
                client = {};
            };
            wireplumber = {
                # enable = true;
                extraConfig = {};
            };
        };
    };
}
