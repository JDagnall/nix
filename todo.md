## Feat

- look into the waybar disappearing when not moused over
- add lang configs for rust, lua and go as in compilers and formatters.
- look into dev shells
- add VPN PrivateInternetAccess connections. Too bad thier openvpn shit is busted
- hyprsunset
- further categorise nix module files into subdirectories
- sessioniser, tmux or not. probably wezterm based

## Fix

- IN GENERAL: look for things that are universal that should be host specific
- Sleep inihibitors
- move window to other monitor keybind for hyprland is a must
- fuzzy matching in rofi
- fix ly terminal session having no stdout. May not be possible untill a PR gets merged in nixpkgs https://github.com/NixOS/nixpkgs/pull/427541
- ly breaks UWSM for some reason
- make sure syncthing folders work effectively, syncthing also often but not always, get a no route available for connecting to devices on local network
- turn off mouse in nix loki maybe
- turn off mouse while typing in hyprland maybe
- turn off password auth for sshd
- nvim-wezterm smartsplits doesnt work properly right now, should be a better config now its on wezterm nightly
- make sure fprintd has fallbacks for password, and try to get more interactive prompts for it on hyprlock and ly.
- check secure boot (nix-community/lanzaboote exists)
- hyprland popup windows
- nvim bracket closing is consistently shite. Additionally Jedi LS is adding brackets when completeing classes. Insanely annoying.

## Sylix

Stylix can be used to theme things universally in nix, use it for theming when it is available

- maybe actually try to get nvim to work with stylix properly, probably will have to pass base 16 as an option, using stylix.
- maybe switch stylix to the wallpaper algorithm
- add host specific stylix config options

### things to be themed in stylix

- ly
