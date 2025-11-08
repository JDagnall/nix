## Feat

- pull alot of my setup config out of the host specific home.nix and into a user config for home-manager
- further categorise nix module files into subdirectories
- hyprsunset
- add VPN PrivateInternetAccess connections. Too bad thier openvpn shit is busted
- sessioniser, tmux or not. probably wezterm based. Maybe do a sessioniser with hyprland workspaces instead of wezterm.
- secure boot (nix-community/lanzaboote exists)
- sops.nix looks like something to look into for secret management
- robust debugger for use in nvim. dont really feel that I need this atm.

## Fix

- Check manual grub entries for windows boot.

- IN GENERAL: look for things that are universal that should be host specific
- Steam does not detect proton GE, and mangohud doesnt load, probably because the steam running commands are being factored in not the lutris ones.
- make sure syncthing folders work effectively, syncthing also often but not always, gets a no route available for connecting to devices on local network
- turn off password auth for sshd
- make sure fprintd has fallbacks for password, and try to get more interactive prompts for it on hyprlock and ly.

- turn off mouse in nix loki maybe

- fix ly terminal session having no stdout. May not be possible untill a PR gets merged in nixpkgs https://github.com/NixOS/nixpkgs/pull/427541
- ly breaks UWSM for some reason

## Sylix

Stylix can be used to theme things universally in nix, use it for theming when it is available

### things to be themed in stylix

- ly
