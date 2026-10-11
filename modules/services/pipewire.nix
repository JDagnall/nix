{...}: {
    flake.modules.nixos.pipewire = {...}: {
        services.pipewire = {
            enable = true;
            extraConfig = {
                pipewire = {};
                jack = {};
                client = {};
            };
            wireplumber = {
                # enable = true;
                extraConfig = {};
            };
        };
    };
}
