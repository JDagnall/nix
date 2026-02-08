{...}: {
	imports = [
		./syncthing.nix
		./docker.nix
		./fprintd.nix
		./pipewire.nix
		./openvpn
		./ssh.nix
		./tailscale.nix
		./jellyfin.nix
		./jackett.nix
		./gnome-keyring.nix
		./wireguard.nix
		./languagetool.nix
	];
}
