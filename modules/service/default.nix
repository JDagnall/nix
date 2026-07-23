{...}: {
    imports = [
        ./syncthing.nix
        ./docker.nix
        ./fprintd.nix
        ./pipewire.nix
        ./vpn
        ./ssh.nix
        ./tailscale.nix
        ./gnome-keyring.nix
        ./languagetool.nix
        ./avahi.nix
        ./dnsmasq.nix
        ./resolved.nix
        ./caddy
        ./media-services
    ];
}
