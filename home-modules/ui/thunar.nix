{
    pkgs,
    lib,
    config,
    ...
}:
{
    options = {
        ui.thunar.enable = lib.mkEnableOption {
            description = "Enable thunar config. Currently includes plugins.";
        };
    };
    config = lib.mkIf config.ui.thunar.enable {
        home.packages =
            with pkgs.xfce;
            [
                thunar
            ]
            ++ [
                thunar-volman # volume manager
                thunar-vcs-plugin # some git integration
                thunar-archive-plugin # managing archive files (extract/compress)
                thunar-media-tags-plugin
            ];
        # stylix.targets.xfce.enable = config.stylix.enableHomeConfig;
    };
}
