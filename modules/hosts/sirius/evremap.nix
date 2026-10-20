{...}: {
    flake.modules.nixos.sirius = {...}: {
        # imports = [];
        config = let
            profiles = {
                logi_k855 = {
                    device_name = "Logitech USB Receiver";
                    remap = [
                        {
                            input = ["KEY_LEFTMETA"];
                            output = ["KEY_LEFTALT"];
                        }
                        {
                            input = ["KEY_LEFTALT"];
                            output = ["KEY_LEFTMETA"];
                        }
                        {
                            input = ["KEY_CAPSLOCK"];
                            output = ["KEY_ESC"];
                        }
                    ];
                };
                keychron-c3 = {
                    device_name = "Keychron Keychron C3 Pro Keyboard";
                    # phys = "usb-0000:09:00.4-2/input2";
                    remap = [
                        {
                            input = ["KEY_LEFTMETA"];
                            output = ["KEY_LEFTALT"];
                        }
                        {
                            input = ["KEY_LEFTALT"];
                            output = ["KEY_LEFTMETA"];
                        }
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
                settings = profiles.keychron-c3;
            };
        };
    };
}
