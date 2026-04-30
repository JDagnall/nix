{...}: {
	imports = [./grub.nix ./systemd-boot.nix];
	config = {
		# kernel modules that should be turned off for every host
		boot.blacklistedKernelModules = [
			"algif_aead" # CVE: 2026-31431
		];
	};
}
