## Feat

- Pull a lot of my setup config out of the host specific home. Nix and into a user
  config for home-manager
- Further categorise nix module files into subdirectories
- Hyprsunset
- Sessioniser, tmux or not. probably wezterm based. Maybe do a sessioniser with Hyprland
  workspaces instead of wezterm.
- Secure boot (nix-community/lanzaboote exists)
- tmux its useful even if don't use it anymore
- Improve Obsidian config to include plugins and configs for them.
- Make a qute browser config, I don't know if I want to actually use it but I find it interesting.
- Noctalia, manage plugins with nix
- rename all hosts
- Declarative config for Jellyfin ( https://github.com/venkyr77/jellarr )
- Declarative config for the Servarr services (https://github.com/nix-media-server/nixarr)
- Nextcloud
- Look for a way to have wezterm change its look in some way based on whether I'm ssh 'd
  into a host at that time. And possibly have custom looks for specific hosts.
- Hyprland moved config to Lua, yay. Update Hyprland config
- Keychain should open on user login
- Remote rebuilding, in a sustainable and secure way. Probably the best way to do this is
  hosting the repo myself on Orion, then using git hooks / a service to push rebuilds to
  each host as they come up. At least on the tailnet.
- Move `media-services` and other similar services to a new module, maybe `servers` or
  something similar.
- Maybe host a git server on Orion and then mirror my repo's there to GitHub and / or
  Codeberg.
- A more declarative and strict way to bind services like Qbittorrent to a VPN / just
  any network interface (https://github.com/Maroka-chan/VPN-Confinement there may be other options).
- Remove old syncthing certs from git history (https://github.com/newren/git-filter-repo).
- Backups for lots of stuff, namely minecraft worlds. Possibly using rdiff-backup which
  does incremental backups.

## Fix

- Check manual grub entries for windows boot.

- IN GENERAL: look for things that are universal that should be host specific
- Centralised place in services config to specify what services are being advertised on a
  system, this is for things like caddy, and dnsmasq to read from.
- Instead of service/services stuff I'm doing, I need to create a `myConfig` namespace
  and move my settings into there so I don't have to worry about option name collisions
- Make sure fprintd has fallbacks for password, and try to get more interactive prompts
  for it on Hyprlock and Ly.
- The ntfs-3g user mapping stuff can be improved, I can create the user-mapping file in
  nix then include it in a mount option. The problem is the windows SID's.
- Fix Ly terminal session having no standard output. Not possible until a PR gets merged
  in nixpkgs https://github.com/NixOS/nixpkgs/pull/427541
- Ly breaks UWSM for some reason
- plasma is totally busted
- Try and create config for Thunar in nix.
- Some kind of slow down on startup with Noctalia, but not always
- Sometimes Hyprland will unfocus from a window and moving to that workspace will not
  refocus, this is a disconnect between whether switching workspaces / windows is moving
  my keyboard or mouse functions or both
- Cannot get SUPER+` keybind, to move focus to other monitor workspace to work in Hyprland
- Hyprland seems to give wrong window sizes to certain application when they are paneled,
  only on framework. Seems to be the case for GTK apps maybe?
- Cannot open terminal from Thunar
- Polkit opens for some things, particularly with network manager for things that
  elevation of privilege is not required.
- When creating a new terminal window/tab in a directory with direnv, it can take a second and commands entered in that period dont take effect, its very annoying

## Stylix

Stylix can be used to theme things universally in nix, use it for theming when it is available

### Things to Be Themed in Stylix

- Ly
