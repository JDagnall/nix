#!/usr/bin/env bash
REPO=/home/james/nix
HOST=$1

set -e
pushd $REPO
echo "Starting ..."
# nixfmt . &>/dev/null
git diff -U0 *.nix
echo "NixOS Rebuilding..."
sudo nixos-rebuild switch --flake $REPO#$HOST &>nixos-switch.log || (
    cat nixos-switch.log | grep --color error && false
)
gen=$(nixos-rebuild list-generations | grep current)
git commit -am "$gen"
pop
echo "Done"
