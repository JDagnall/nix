## My Configs in Nix!

#### Brief Overview

- I use [sops-nix](https://github.com/mic92/sops-nix) to manage my secrets.
- I use [Stylix](https://github.com/nix-community/stylix) to theme most of the applications I use.
- My Neovim configuration is in another repo [here](https://github.com/JDagnall/NixLoki)
- In general the modules as they are written try to be as user agnostic as possible but
  they are definetly not perfect and do sometimes contain user specific configuration / preferences.
  For example, my Hyprland and wezterm configuration should probably be brought under my user
  configuration in `modules/users/james` but I have yet to do that.
- The repo generally follows the dendritic pattern, I make extensive use of interface
  patterns. Nix does not like it when you import modules more than once, that are not imported
  as files (the absolute path is used as a key to check for duplicate imports.), the key parameter
  in a module fixes this. Modules that define options will cause an error if imported twice (unless
  the have a key.).
