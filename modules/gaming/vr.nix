{
    pkgs,
    lib,
    config,
    ...
}: {
    options = {
        gaming.vr.enable = lib.mkEnableOption "Enable VR configuration";
        gaming.vr.wivrn.enable = lib.mkEnableOption "Enable WiVRn, a wireless VR streamer";
        gaming.vr.alvr.enable = lib.mkEnableOption "Enable ALVR, a wireless VR streamer";
    };
    config = let
        # PROBABLY UNEEDED NOW
        # getting an old nixpkgs-unstable where the wayvr version is one down "26.2" to prevent an screen stretching issue
        # will be able to remove this soon when the WiVRn and Monado packages in nixpkgs catch up
        # see here https://github.com/wlx-team/wayvr/issues/441
        # oldWayvrPkgs = import (fetchTarball {
        #     url = "https://github.com/NixOS/nixpkgs/archive/10de3cd61e76921c7b2821baa41fbd57f28be6fe.tar.gz";
        #     sha256 = "sha256:0yjzp3v6mm6wg9jgg60pvara4wpyg0xif13jbd7wjm65mxng4j89";
        # }) {inherit (pkgs.stdenv.hostPlatform) system;};
        # # the wivrn version on the meta store is super slow to update,
        # # and versions need to be identical so im holding the wivrn version back
        # oldWivrnPkgs = import (fetchTarball {
        #     url = "https://github.com/NixOS/nixpkgs/archive/c5dd43934613ae0f8ff37c59f61c507c2e8f980d.tar.gz";
        #     sha256 = "sha256:1cpw3m45v7s7bm9mi750dkdyjgd2gp2vq0y7vr3j42ifw1i85gxv";
        # }) {inherit (pkgs.stdenv.hostPlatform) system;};
    in
        lib.mkIf config.gaming.vr.enable {
            services.wivrn = lib.mkIf config.gaming.vr.wivrn.enable {
                enable = true;
                # package = pkgs.wivrn;
                config = {
                    enable = true;
                    json = {
                        # encoder = [ # can manually configure encoders
                        # ];
                        openvr-compat-path = "${pkgs.xrizer}/lib/xrizer";
                        # application = [oldWayvrPkgs.wayvr]; # start on connect
                        application = [pkgs.wayvr]; # start on connect
                    };
                };
                openFirewall = true;
                steam = {
                    enable = true;
                    importOXRRuntimes = true;
                    package = config.programs.steam.package;
                };
                monadoEnvironment = {
                    STEAMVR_LH_ENABLE = "1";
                    XRT_COMPOSITOR_COMPUTE = "1";
                };
                highPriority = true; # high prio capability for async reprojection ?????
                # I wanna start this manually
                autoStart = false;
            };
            environment.systemPackages = lib.mkIf config.gaming.vr.wivrn.enable [pkgs.xrizer];
            # needed by wivrn
            services.monado = lib.mkIf config.gaming.vr.wivrn.enable {
                enable = true;
                # package =;
                highPriority = true;
                forceDefaultRuntime = true;
                defaultRuntime = true;
            };
            # I want the monado service will start automatically i also want it to close automatically
            systemd.user.services.monado.environment."IPC_EXIT_WHEN_IDLE" = lib.mkIf config.gaming.vr.wivrn.enable "1";
            systemd.user.services.monado.environment."IPC_EXIT_WHEN_IDLE_DELAY_MS" = lib.mkIf config.gaming.vr.wivrn.enable "600000"; # 10 min
            programs.alvr = lib.mkIf config.gaming.vr.alvr.enable {
                enable = true;
                openFirewall = true;
            };
        };
}
