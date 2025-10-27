{...}: {
	imports = [
		./syncthing
		./docker.nix
		./fprintd.nix
		./openvpn.nix
		./pipewire.nix
	];
}
