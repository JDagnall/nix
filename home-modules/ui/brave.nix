{
    lib,
    config,
    ...
}: {
    options = {
        ui.brave.enable = lib.mkEnableOption "Enable brave config";
    };
    config = lib.mkIf config.ui.brave.enable {
        programs.brave.enable = true;
    };
}
