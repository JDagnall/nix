## Feat

- pull alot of my setup config out of the host specific home.nix and into a user config for home-manager
- further categorise nix module files into subdirectories
- hyprsunset
- sessioniser, tmux or not. probably wezterm based. Maybe do a sessioniser with hyprland workspaces instead of wezterm.
- secure boot (nix-community/lanzaboote exists)
- robust debugger for use in nvim. dont really feel that I need this atm.
- tmux its useful even if dont use it anymore

## Fix

- Check manual grub entries for windows boot.

- IN GENERAL: look for things that are universal that should be host specific
- This namespace duplication stuff with service / services is unnecesary, cant use the same namespaces as nixpkgs because it will cause infinite recursion. Should maybe do a separate namespaces to put my options in.
- Steam does not detect proton GE, and mangohud doesnt load, probably because the steam running commands are being factored in not the lutris ones.
- make sure fprintd has fallbacks for password, and try to get more interactive prompts for it on hyprlock and ly.
- nvim bracket closing is shite, needs <> added as well
- rust-analyzer only lints on file save
- the ntfs-3g user mapping stuff can be improved, I can create the usermapping file in nix then include it in a mount option. the problem is the windows SID's.
- turn off mouse in nix loki maybe
- fix ly terminal session having no stdout. Not possible untill a PR gets merged in nixpkgs https://github.com/NixOS/nixpkgs/pull/427541
- ly breaks UWSM for some reason
- plasma is totally busted
- try and create config for thunar in nix.

## Stylix

Stylix can be used to theme things universally in nix, use it for theming when it is available

### things to be themed in stylix

- ly
