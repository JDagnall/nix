{
    pkgs,
    lib,
    config,
    ...
}:
let
    inherit (lib) mkEnableOption mkIf;
    inherit (config) ui;
    inherit (config.window-manager) hyprland;
in
{
    options = {
        ui.hypr-screenshot.enable = mkEnableOption {
            description = ''
                Enable config for screenshot / recording utilities in hyprland.
            '';
        };
    };
    config = mkIf ui.hypr-screenshot.enable {

        assertions = [
            {
                assertion = hyprland.enable;
                message = "This screenshot config requires hyprland, disable it or enable hyprland.";
            }
        ];
        # this is just to create the screenshots directory
        home.file."screenshots/keep" = {
            enable = true;
            text = "";
            recursive = true;
        };
        home.packages =
            with pkgs;
            let
                # create these scripts then add them to PATH so they can be used
                screencap-screen-script = pkgs.writeShellApplication {
                    name = "screencap-screen-script";
                    runtimeInputs = [
                        grim
                        swappy
                    ];
                    text = "grim - | swappy -f - ";

                };
                screencap-select-script = pkgs.writeShellApplication {
                    name = "screencap-select-script";
                    runtimeInputs = [
                        grim
                        slurp
                        swappy
                    ];
                    text = "grim -g \"\$(slurp)\" - | swappy -f - ";

                };
                screenrec-select-script = pkgs.writeShellApplication {
                    name = "screenrec-select-script";
                    runtimeInputs = [
                        wf-recorder
                        slurp
                    ];
                    text = "wf-recorder -g \"\$(slurp)\" -f ~/screenshots/screenrec-\"\$(date +%Y-%m-%d_%H:%M)\".mp4";

                };
                screenrec-screen-script = pkgs.writeShellApplication {
                    name = "screenrec-screen-script";
                    runtimeInputs = [
                        wf-recorder
                    ];
                    text = "wf-recorder -f ~/screenshots/screenrec-\"\$(date +%Y-%m-%d_%H:%M)\".mp4";

                };

            in
            [
                grim
                slurp
                swappy
                wf-recorder
                screencap-screen-script
                screencap-select-script
                screenrec-screen-script
                screenrec-select-script
            ];
        wayland.windowManager.hyprland.settings.bind = [
            ''$mod SHIFT, s, exec, screencap-select-script''
            '',Print, exec, screencap-screen-script''
        ];
        # swappy config
        xdg.configFile."swappy/config".text = ''
            [Default]
            save_dir=${config.home.homeDirectory}/screenshots
            save_filename_format=swappy-%Y-%m-%d_%H:%M.png
        '';

        xdg.desktopEntries = {
            screencap-screen-script = {
                name = "Screen Capture Entire Screen";
                exec = "screencap-screen-script";
                terminal = false;
                type = "Application";
                categories = [
                    "Utility"
                ];
            };
            screencap-select-script = {
                name = "Screen Capture Region";
                exec = "screencap-select-script";
                terminal = false;
                type = "Application";
                categories = [
                    "Utility"
                ];
            };
            screenrec-screen-script = {
                name = "Screen Record Entire Screen";
                exec = "screenrec-screen-script";
                terminal = true;
                type = "Application";
                categories = [
                    "Recorder"
                    "Utility"
                ];
            };
            screenrec-select-script = {
                name = "Screen Record Selection";
                exec = "screenrec-select-script";
                terminal = true;
                type = "Application";
                categories = [
                    "Recorder"
                    "Utility"
                ];
            };
        };

    };

}
