{...}: {
    flake.modules.homeManager.thunar = {pkgs, ...}: {
        config = {
            # TODO: need to find a way to configure this
            home.packages = with pkgs; [
                thunar
                xfconf # needed for configuration
                thunar-volman # volume manager
                thunar-vcs-plugin # some git integration
                thunar-archive-plugin # managing archive files (extract/compress)
                thunar-media-tags-plugin
            ];
            dbus.packages = with pkgs; [thunar xfconf];
            # stylix.targets.xfce.enable = config.stylix.enableHomeConfig;
        };
    };
}
