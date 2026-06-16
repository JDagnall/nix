{
    config,
    pkgs,
    ...
}: {
    # config ------------------------------
    boot-loader.systemd-boot.enable = true;
    fonts.enable = true;
    sops.enable = true;

    service.sshd.enable = true;
    service.sshd.james.authKeys.enable = true;
    services.avahi.enable = true;
    service.tailscale = {
        enable = true;
        physicalInterfaces = ["enp34s0"];
    };
    service.tailscale.tailnet = "stonecat-barometric";
    service.languagetool.enable = false;
    service.wiregaurd.enable = true;
    service.openvpn.enable = true;
    service.caddy.enable = true;
    service.dnsmasq = {
        enable = true;
        localNetworkInterface = "enp34s0";
    };

    service.media-services = {
        enable = true;
        jellyfin = {
            enable = true;
            enableGpuTranscoding = true;
        };
        qbittorrent.enable = true;
        sonarr.enable = true;
        radarr.enable = true;
        prowlarr.enable = true;
        seerr.enable = true;
    };
    service.openvpn.PIAqBittorrentService = true;

    service.syncthing = {
        enable = true;
        devices = {
            PC.enable = true;
            macbook.enable = true;
            framework.enable = true;
            galaxy-s10e.enable = true;
        };
        folders = {
            secure.enable = true;
            secure.share = ["PC" "Galaxy-s10e" "Macbook" "Framework"];
            classes.enable = true;
            classes.share = ["PC" "Framework"];
            proj.enable = true;
            proj.share = ["PC" "Framework"];
            wallpapers.enable = true;
            wallpapers.share = ["PC" "Macbook" "Framework"];
            docs.enable = true;
            docs.share = ["PC" "Framework" "Macbook" "Galaxy-s10e"];
        };
        gui.enableLogin = true;
        gui.setDefaultRoute = true;
    };

    gaming.minecraft-servers = {
        enable = false;
        "1.21.10" = false;
    };

    stylix.enableConfig = true;

    # config ------------------------------

    imports = [
        # Include the results of the hardware scan.
        ./hardware-configuration.nix
        ../../james.nix
        ../../modules
        ../../stylix.nix
        ../../sops.nix
        ./stylix.nix
    ];

    environment.systemPackages = with pkgs; [home-manager];

    nix.settings.experimental-features = [
        "nix-command"
        "flakes"
    ];
    networking.networkmanager.enable = true;
    networking.hostName = "orion";
    # allow wake on lan with magic packet for this computer
    networking.interfaces."enp34s0".wakeOnLan = {
        enable = true;
        policy = ["magic"];
    };

    # garbage collector
    nix.gc = {
        automatic = true;
        dates = "weekly";
        persistent = true;
        randomizedDelaySec = "10min";
        options = "-d";
    };

    time.timeZone = "Australia/Brisbane";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_GB.UTF-8";

    i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_AU.UTF-8";
        LC_IDENTIFICATION = "en_AU.UTF-8";
        LC_MEASUREMENT = "en_AU.UTF-8";
        LC_MONETARY = "en_AU.UTF-8";
        LC_NAME = "en_AU.UTF-8";
        LC_NUMERIC = "en_AU.UTF-8";
        LC_PAPER = "en_AU.UTF-8";
        LC_TELEPHONE = "en_AU.UTF-8";
        LC_TIME = "en_AU.UTF-8";
    };

    console = {
        font = "Lat2-Terminus16";
        keyMap = "us";
        #useXkbConfig = true; # use xkb.options in tty.
    };

    # use latest linux kernal
    # temporarily using older kernel for the iso
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # adds list of currently used system packages to /etc/nixos/current-system-packages
    environment.etc."current-system-packages".text = let
        packages = map (p: "${p.name}") config.environment.systemPackages;
        sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
        formatted = builtins.concatStringsSep "\n" sortedUnique;
    in
        formatted;

    system.stateVersion = "25.11"; # Did you read the comment?
}
