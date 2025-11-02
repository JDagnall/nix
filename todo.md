## Feat

- pull alot of my setup config out of the host specific home.nix and into a user config for home-manager
- look into the waybar disappearing when not moused over
- add lang configs for rust, lua and go as in compilers and formatters.
- look into dev shells
- add VPN PrivateInternetAccess connections. Too bad thier openvpn shit is busted
- hyprsunset
- further categorise nix module files into subdirectories
- sessioniser, tmux or not. probably wezterm based
- Sleep inihibitors, theres one that checks pipewire, for audio and inhibit sleep. Should maybe make my own button in waybar for it using systemd-inhibit
- fuzzy matching in rofi
- move window to other monitor keybind for hyprland is a must
- secure boot (nix-community/lanzaboote exists)
- make nix-shell use my shell config. Can also apparently do things like looks for Pipenv files and download the required packages etc.
- robust debugger for use in nvim. dont really feel that I need this atm.
- sops.nix looks like something to look into for secret management

## Fix

- IN GENERAL: look for things that are universal that should be host specific
- workspace indicator on waybar should show the displayed workspace on the monitor the bar is on, not what is selected in general.
- Steam does not detect proton GE
- Should probably manually do grub entries the OS-prober is annoying
- fix ly terminal session having no stdout. May not be possible untill a PR gets merged in nixpkgs https://github.com/NixOS/nixpkgs/pull/427541
- ly breaks UWSM for some reason
- make sure syncthing folders work effectively, syncthing also often but not always, get a no route available for connecting to devices on local network
- turn off mouse in nix loki maybe
- turn off mouse while typing in hyprland maybe
- turn off password auth for sshd
- nvim-wezterm smartsplits doesnt work properly right now, should be a better config now its on wezterm nightly
- make sure fprintd has fallbacks for password, and try to get more interactive prompts for it on hyprlock and ly.
- nvim bracket closing is consistently shite. Additionally Jedi LS is adding brackets when completeing classes. Insanely annoying.

## Sylix

Stylix can be used to theme things universally in nix, use it for theming when it is available

- maybe actually try to get nvim to work with stylix properly, probably will have to pass base 16 as an option, using stylix.
- maybe switch stylix to the wallpaper algorithm
- add host specific stylix config options

### things to be themed in stylix

- ly
