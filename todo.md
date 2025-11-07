## Feat

- pull alot of my setup config out of the host specific home.nix and into a user config for home-manager
- further categorise nix module files into subdirectories
- add VPN PrivateInternetAccess connections. Too bad thier openvpn shit is busted
- hyprsunset
- sessioniser, tmux or not. probably wezterm based
- Sleep inihibitors, theres one that checks pipewire, for audio and inhibit sleep. Should maybe make my own button in waybar for it using dbus
- secure boot (nix-community/lanzaboote exists)
- sops.nix looks like something to look into for secret management
- robust debugger for use in nvim. dont really feel that I need this atm.
- way better tab names for wezterm

## Fix

- Should probably manually do grub entries the OS-prober is annoying

- IN GENERAL: look for things that are universal that should be host specific
- workspace indicator on waybar should show the displayed workspace on the monitor the bar is on, not what is selected in general.
- Steam does not detect proton GE
- make sure syncthing folders work effectively, syncthing also often but not always, get a no route available for connecting to devices on local network
- turn off password auth for sshd
- make sure fprintd has fallbacks for password, and try to get more interactive prompts for it on hyprlock and ly.

- turn off mouse in nix loki maybe
- nvim-wezterm smartsplits doesnt work properly right now, should be a better config now its on wezterm nightly
- nvim bracket closing is consistently shite. Additionally Jedi LS is adding brackets when completeing classes. Insanely annoying.
- nvim improve gitsigns config, with keybinds for showing blame and stuff

- fix ly terminal session having no stdout. May not be possible untill a PR gets merged in nixpkgs https://github.com/NixOS/nixpkgs/pull/427541
- ly breaks UWSM for some reason

## Sylix

Stylix can be used to theme things universally in nix, use it for theming when it is available

### things to be themed in stylix

- ly
