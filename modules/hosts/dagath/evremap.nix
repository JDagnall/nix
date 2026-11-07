{...}: {
    flake.modules.nixos.dagath = {...}: {
        # imports = [];
        config = let
            profiles = {
                dagath = {
                    phys = "01:15:02:01:00";
                    device_name = "Microsoft Surface 045E:09AE Keyboard";
                    remap = [
                        {
                            input = ["KEY_CAPSLOCK"];
                            output = ["KEY_ESC"];
                        }
                        {
                            input = ["KEY_LEFTMETA"];
                            output = ["KEY_LEFTALT"];
                        }
                        {
                            input = ["KEY_LEFTALT"];
                            output = ["KEY_LEFTMETA"];
                        }
                    ];
                };
            };
        in {
            services.evremap = {
                enable = true;
                settings = profiles.dagath;
            };
        };
    };
}
