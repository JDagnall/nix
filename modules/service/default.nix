{...}: {
	imports = [
		./syncthing
		./docker.nix
		./fprintd.nix
		./pipewire.nix
		./openvpn
		./ssh.nix
	];
}
