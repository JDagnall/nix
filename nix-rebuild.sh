#!/bin/bash
REPO=~/nix
HOST=$1

set -e
pushd $REPO
nixfmt . &>/dev/null
git diff -U0 *.nix
echo "NixOS Rebuilding..."
sudo nixos-rebuild switch --flake $REPO#$HOST &>nixos-switch.log || (
    cat nixos-switch.log | grep --color error && false
)
gen=$(nixos-rebuild list-generations | grep current)
git commit -am "$gen"
pop
