## Ideas

- improve waybar config, more/ better status indicators, personalise CSS more, look into the waybar disappearing when not moused over
- applets for things like power menu, bluetooth, wifi, and audio for the waybar
- volume and brightness indicator when changing maybe.
- setup passkey auth with fingerprint sensor, libfprint / fprintd
- speed up animation in hyprland
- fix ly terminal session having no stdout
- make sure auth through dbus works for things like vscode with github. Seems to.
- simple vscode config for PR's with TA. Or other method for PRs
- switch to alejandra in nvim and rebuild scripts
- add lang configs for rust and go as in compilers and formatters.
- make sure syncthing folders work effectively
- look into keepassxc auto type on wayland. seems it needs an X11 backend, keepmenu seems to be a solution to this with dmenu, look into configuring it
- turn off mouse in nix loki maybe
- turn off mouse while typing in hyprland maybe
- stop mousing over changes window selection in hyprland
- turn off password auth for sshd
- look into dev shells
- try ghostty
- telescope in nvim is not transparent when using stylix
- nvim-wezterm smartsplits doesnt work properly right now, should be a better config now its on wezterm nightly
- obsidian
- maybe switch electron apps to flatpak
- gh cli
- nvim telescope search for functions in buffer.

## Sylix

Stylix can be used to theme things universally in nix, use it for theming when it is available

### things to be themed in stylix

- wezterm DONE, tab selected color is too gray and nvim telescope is not transparent
- rofi DONE
- hyprland DONE
- waybar DONE
- cmd line utilites? DONE
- grub
- ly
- hyprlock DONE
