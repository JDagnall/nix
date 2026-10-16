{...}: {
    flake.modules.nixos.framework = {...}: {
        # imports = [];
        config = let
            profiles = {
                framework = {
                    phys = "isa0060/serio0/input0";
                    device_name = "AT Translated Set 2 keyboard";
                    remap = [
                        {
                            input = ["KEY_CAPSLOCK"];
                            output = ["KEY_ESC"];
                        }
                        {
                            input = ["KEY_LEFTALT"];
                            output = ["KEY_LEFTMETA"];
                        }
                        {
                            input = ["KEY_LEFTMETA"];
                            output = ["KEY_LEFTALT"];
                        }
                    ];
                };
            };
        in {
            services.evremap = {
                enable = true;
                settings = profiles.framework;
            };
        };
    };
}
