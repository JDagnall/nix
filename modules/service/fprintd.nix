{
    lib,
    config,
    ...
}: {
    options = {
        service.fprintd.enable = lib.mkEnableOption {
            description = "Enable fprintd, daemon for fingerprint auth.";
        };
    };
    config = lib.mkIf config.service.fprintd.enable {
        services.fprintd = {
            enable = true;
        };
        # pam automatically enables fingerprint auth if fprintd is enabled for users
        # to turn it of for a user do
        # security.pam.services."name".fprintAuth = false;
    };
}
