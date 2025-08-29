{
    lib,
    config,
    ...
}:
{
    options = {
        shell.spotify-player.enable = lib.mkEnableOption { description = "Enable spotify-player config."; };
    };
    config = lib.mkIf config.shell.spotify-player.enable {
        programs.spotify-player = {
            enable = true;
            settings = {};
        };
        stylix.targets.spotify-player.enable = config.stylix.enableHomeConfig;

    };
}
