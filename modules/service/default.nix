{...}: {
	imports = [
		./syncthing.nix
		./docker.nix
		./fprintd.nix
		./pipewire.nix
		./openvpn
		./ssh.nix
		./tailscale.nix
	];
}
