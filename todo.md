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
- look for a way to have wezterm change its look in some way based on whether im ssh'd into a host at that time. And possibly have custom looks for specific hosts.
- hyprland moved config to lua, yay. update hyprland config
- keychain should open on user login

## Fix

- Check manual grub entries for windows boot.

- IN GENERAL: look for things that are universal that should be host specific
- when creating a new terminal window/tab in a directory with direnv, it can take a second and commands entered in that period dont take effect, its very annoying
- Instead of service/services stuff im doing, I need to create a `myConfig` namespace and move my settings into there so I dont have to worry about option name collisions
- make sure fprintd has fallbacks for password, and try to get more interactive prompts for it on hyprlock and ly.
- the ntfs-3g user mapping stuff can be improved, I can create the usermapping file in nix then include it in a mount option. the problem is the windows SID's.
- fix ly terminal session having no stdout. Not possible untill a PR gets merged in nixpkgs https://github.com/NixOS/nixpkgs/pull/427541
- ly breaks UWSM for some reason
- plasma is totally busted
- try and create config for thunar in nix.
- some kind of slow down on startup with noctalia, but not always
- sometimes hyprland will unfocus from a window and moving to that workspace will not refocus, this is a disconnect between whether switching workspaces / windows is moving my keyboard or mouse functions or both
- cannot get SUPER+` keybind, to move focus to other monitor workspace to work in hyprland
- hyprland seems to give wrong window sizes to certain application when they are paneled, only on framework.
- cannot open terminal from thunar
- Make all services that use the drive, run as the drive group instead of just being a part of it.

## Stylix

Stylix can be used to theme things universally in nix, use it for theming when it is available

### things to be themed in stylix

- ly
