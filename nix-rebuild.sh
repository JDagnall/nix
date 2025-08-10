#!/usr/bin/env bash
REPO=/home/james/nix
HOST=$1

set -e
pushd $REPO
echo "Starting ..."
# nixfmt . &>/dev/null
git diff -U0 *.nix
echo "NixOS Rebuilding..."
nixos-rebuild switch --use-remote-sudo --flake $REPO#$HOST &>nixos-switch.log || (
    cat nixos-switch.log | grep --color error && false
)
gen="NixOs: $(nixos-rebuild list-generations | grep true)"
git commit -am "$gen"
popd
echo "Done"
