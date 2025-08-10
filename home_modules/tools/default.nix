{
    pkgs,
    lib,
    config,
    ...
}:
{
    imports = [
        ./git.nix
        ./keepassxc.nix
    ];
    # tools which just need to be enabled with no other config
    options = {
        tools.pipenv.enable = lib.mkEnableOption {
            default = false;
            description = "enable pipenv";
        };
        tools.mycli.enable = lib.mkEnableOption {
            default = false;
            description = "enable mycli";
        };
    };
    config =
        let
            inherit (config.tools) pipenv mycli;
        in
        {
            home.packages =
                [ ]
                ++ (if pipenv.enable then [ pkgs.pipenv ] else [ ])
                ++ (if mycli.enable then [ pkgs.mycli ] else [ ]);

        };
}
