{
    lib,
    config,
    ...
}: {
    options = {
        service.gnome-keyring.enable = lib.mkEnableOption "Enable gnome-keyring config";
    };
    config = lib.mkIf config.service.gnome-keyring.enable {
        services.gnome.gnome-keyring.enable = true;
        # will attempt to unlock keyring with users password on login
        security.pam.services.james.enableGnomeKeyring = true;
    };
}
