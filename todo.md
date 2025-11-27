## Feat

- pull alot of my setup config out of the host specific home.nix and into a user config for home-manager
- further categorise nix module files into subdirectories
- hyprsunset
- sessioniser, tmux or not. probably wezterm based. Maybe do a sessioniser with hyprland workspaces instead of wezterm.
- secure boot (nix-community/lanzaboote exists)
- robust debugger for use in nvim. dont really feel that I need this atm.
- clipboard utility

## Fix

- Check manual grub entries for windows boot.

- IN GENERAL: look for things that are universal that should be host specific
- I should change the namespaces of my config to match nixpkgs / home-manager. This namespace duplication stuff with service / services is unecesary, there will only be minor naming conflicts.
- Steam does not detect proton GE, and mangohud doesnt load, probably because the steam running commands are being factored in not the lutris ones.
- make sure fprintd has fallbacks for password, and try to get more interactive prompts for it on hyprlock and ly.

- turn off mouse in nix loki maybe

- fix ly terminal session having no stdout. May not be possible untill a PR gets merged in nixpkgs https://github.com/NixOS/nixpkgs/pull/427541
- ly breaks UWSM for some reason

## Sylix

Stylix can be used to theme things universally in nix, use it for theming when it is available

### things to be themed in stylix

- ly
