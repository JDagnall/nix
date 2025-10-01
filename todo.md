## Feat

- look into the waybar disappearing when not moused over
- add lang configs for rust, lua and go as in compilers and formatters.
- look into dev shells
- add VPN PrivateInternetAccess connections. Too bad thier openvpn shit is busted
- hyprsunset
- further categorise nix module files into subdirectories
- sessioniser, tmux or not

## Fix

- fix ly terminal session having no stdout. May not be possible untill a PR gets merged in nixpkgs https://github.com/NixOS/nixpkgs/pull/427541
- ly breaks UWSM for some reason
- make sure auth through dbus works for things like vscode with github. Seems to.
- make sure syncthing folders work effectively, syncthing also often but not always, get a no route available for connecting to devices on local network
- turn off mouse in nix loki maybe
- turn off mouse while typing in hyprland maybe
- stop mousing over changes window selection in hyprland
- turn off password auth for sshd
- nvim-wezterm smartsplits doesnt work properly right now, should be a better config now its on wezterm nightly
- make sure fprintd has fallbacks for password, and try to get more interactive prompts for it on hyprlock and ly.
- check secure boot (nix-community/lanzaboote exists)
- hyprland popup windows

## Sylix

Stylix can be used to theme things universally in nix, use it for theming when it is available

### things to be themed in stylix

- wezterm DONE, tab selected color is too gray and nvim telescope is not transparent
- rofi DONE
- hyprland DONE
- waybar DONE
- cmd line utilites? DONE
- grub DONE
- ly
- hyprlock DONE
