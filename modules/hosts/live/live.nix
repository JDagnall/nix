# This is a configuration specifically for a live usb, meant to install nixos
# use `nix build .#nixosConfigurations.live.config.system.build.isoImage` to build it
# To load secrets onto the iso such as sops secret keys, use:
# ```sh
# xorriso -indev [BUILT ISO FILE] -outdev [OUTPUT ISO FILE] \
#   -map [PATH TO KEY] [KEY LOCATION IN ISO] \
#   -boot_image any replay
# ```
{
    self,
    lib,
    inputs,
    ...
}: {
    flake.modules.nixos.live = {pkgs, ...}: {
        imports = with self.modules.nixos; [
            base
            live-james
            "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ];
        config = {
            boot.kernelPackages = pkgs.linuxPackages_6_18;
            # add things to the iso file system
            isoImage.contents = [
                {
                    source = self;
                    target = "/flake";
                }
            ];
            # isoImage.storeContents = [
            #     # Could choose to load closures onto
            #     #  the system if it does not have internet access etc..
            #     # self.nixosConfigurations.[HOSTNAME].config.system.build.toplevel
            # ];

            nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

            # could add a password authed ssh so that
            # I could easily move files on, but the whole point of this
            # is that I hopefully wont have to
        };
    };
    flake.nixosConfigurations.live = inputs.nixpkgs.lib.nixosSystem {
        modules = [self.modules.nixos.live];
    };
}
