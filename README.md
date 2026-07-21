## My Configs in Nix!

#### Brief Overview

- The repo is split down the middle with `home-modules` ([home-manger](https://github.com/nix-community/home-manager))
  and `modules` (NixOS) although I currently use home-manager as a NixOS module. I am
  looking to fix this split with the dendritic pattern sometime soon.
- I use [sops-nix](https://github.com/mic92/sops-nix) to manage my secrets.
- I use [Stylix](https://github.com/nix-community/stylix) to theme most of the applications I use.
- My Neovim config is in another repo [here](https://github.com/JDagnall/NixLoki)
- In general the modules as they are written try to be as host agnostic as possible but
  they are definetly not perfect and do sometimes contain host specific config. This is
  another thing I plan to fix with the dendritic pattern (eventually).
