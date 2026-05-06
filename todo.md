## Feat

- pull alot of my setup config out of the host specific home.nix and into a user config for home-manager
- further categorise nix module files into subdirectories
- hyprsunset
- sessioniser, tmux or not. probably wezterm based. Maybe do a sessioniser with hyprland workspaces instead of wezterm.
- secure boot (nix-community/lanzaboote exists)
- tmux its useful even if dont use it anymore
- improve obsidian config to include plugins and configs for them.
- make a qute browser config, idk if I want to actually use it but I find it interesting.
- noctalia, manage plugins with nix
- rename all hosts
- declarative config for jellyfin https://github.com/venkyr77/jellarr
- nextcloud
- pihole to define give subdomain to open ports for services
- qbitorrent webclient for orion with jackett. Will require gaurantee that the connection goes through a vpn

## Fix

- Check manual grub entries for windows boot.

- IN GENERAL: look for things that are universal that should be host specific
- This namespace duplication stuff with service / services is unnecesary, cant use the same namespaces as nixpkgs because it will cause infinite recursion. Should maybe do a separate namespaces to put my options in.
- make sure fprintd has fallbacks for password, and try to get more interactive prompts for it on hyprlock and ly.
- the ntfs-3g user mapping stuff can be improved, I can create the usermapping file in nix then include it in a mount option. the problem is the windows SID's.
- fix ly terminal session having no stdout. Not possible untill a PR gets merged in nixpkgs https://github.com/NixOS/nixpkgs/pull/427541
- ly breaks UWSM for some reason
- plasma is totally busted
- try and create config for thunar in nix.
- some kind of slow down on startup with noctalia, but not always
- sometimes hyprland will unfocus from a window and moving to that workspace will not refocus
- cannot get SUPER+` keybind, to move focus to other monitor workspace to work in hyprland
- hyprland seems to give wrong window sizes to certain application when they are paneled, only on framework.
- cannot open terminal from thunar

## Stylix

Stylix can be used to theme things universally in nix, use it for theming when it is available

### things to be themed in stylix

- ly
