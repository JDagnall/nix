## Feat

- look into the waybar disappearing when not moused over
- look into good rebuild script
- add lang configs for rust and go as in compilers and formatters.
- look into dev shells
- nvim telescope search for functions in buffer.
- add VPN PrivateInternetAccess connections. Too bad thier openvpn shit is busted
- hyprsunset
- hyprland pane resizing
- further categorise nix module files into subdirectories
- try ghostty
- sessioniser, tmux or not
- switch to alejandra in nvim and rebuild scripts

## Fix

- fix ly terminal session having no stdout. May not be possible untill a PR gets merged in nixpkgs https://github.com/NixOS/nixpkgs/pull/427541
- ly breaks UWSM for some reason
- make sure auth through dbus works for things like vscode with github. Seems to.
- make sure syncthing folders work effectively, syncthing also often but not always, get a no route available for connecting to devices on local network
- turn off mouse in nix loki maybe
- turn off mouse while typing in hyprland maybe
- stop mousing over changes window selection in hyprland
- turn off password auth for sshd
- telescope in nvim is not transparent when using stylix. might just be hl groups
- nvim-wezterm smartsplits doesnt work properly right now, should be a better config now its on wezterm nightly
- make sure fprintd has fallbacks for password, and try to get more interactive prompts for it on hyprlock and ly.
- check secure boot (nix-community/lanzaboote exists)
- git delta colours are annoying
- hyprland popup windows
- nvim clipboard to detect wsl or otherwise

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
