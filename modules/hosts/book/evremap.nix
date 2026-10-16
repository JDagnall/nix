{...}: {
    flake.modules.nixos.book = {...}: {
        # imports = [];
        config = let
            profiles = {
                book = {
                    phys = "usb-0000:00:14.0-5/input1";
                    device_name = "Apple Inc. Apple Internal Keyboard / Trackpad";
                    remap = [
                        {
                            input = ["KEY_CAPSLOCK"];
                            output = ["KEY_ESC"];
                        }
                    ];
                };
            };
        in {
            services.evremap = {
                enable = true;
                settings = profiles.book;
            };
        };
    };
}
