{...}: {
    imports = [./bat.nix ./ssh.nix ./eza.nix ./fzf.nix ./zoxide.nix ./zsh.nix ./spotify-player.nix];
    config = {
        home.shellAliases = {
            ls = "ls -lahH --color=auto";
            py = "python3";
            sudo = "sudo ";
            c = "clear";
            cls = "clear";

            grep = "grep --color=auto";
            fgrep = "fgrep --color=auto";
            egrep = "egrep --color=auto";
            diff = "diff --color=auto";
            ip = "ip --color=auto";
            ll = "ls -l";
            la = "ls -A";
            l = "ls -CF";

            # have nix-shell spit me into my shell not bash
            nix-shell = "nix-shell --run $SHELL";
        };
    };
}
