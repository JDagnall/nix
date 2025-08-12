## Ideas

- speed up animation in hyprland
- improve waybar config, more/ better status indicators, personalise CSS more, look into the waybar disappearing when not moused over
- applets for things like power menu, bluetooth, wifi, and audio for the waybar
- do dependecy stuff, try to create an assertion with an error message
- hyprlock stuff
- fix ly terminal session having no stdout
- set wallpaper for autostart with hyprland, make sure its in an option
- configure autostarts in hyprland using nix options for whats enabled
- setup passkey auth with fingerprint sensor, libfprint / fprintd
- make sure auth through dbus works for things like vscode with github. Seems to.
- simple vscode config for PR's with TA. Or other method for PRs
- switch to alejandra in nvim and rebuild scripts
- add lang configs for rust and go as in compilers and foramtters.
- make sure syncthing folders work effectively
- look into keepassxc auto type on wayland. seems it needs an X11 backend, keepmenu seems to be a solution to this with dmenu, look into configuring it
- notification daemon. Electron apps will require it.
- maybe do electron apps like discord, slack and obsidian with flatpak or something.
- turn off mouse in nix loki maybe
- turn off mouse while typing in hyprland maybe
- stop mousing over changes window selection in hyprland
- turn off password auth for sshd
- look into dev shells

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
- hyprlock
