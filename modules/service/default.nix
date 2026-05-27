{...}: {
    imports = [
        ./syncthing.nix
        ./docker.nix
        ./fprintd.nix
        ./pipewire.nix
        ./openvpn
        ./ssh.nix
        ./tailscale.nix
        ./gnome-keyring.nix
        ./wireguard.nix
        ./languagetool.nix
        ./avahi.nix
        ./dnsmasq.nix
        ./caddy
        ./media-services
    ];
}
