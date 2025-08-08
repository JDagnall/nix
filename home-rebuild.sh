#!/bin/bash
REPO=~/nix
HOST=$1

set -e
pushd $REPO
nixfmt . &>/dev/null
git diff -U0 *.nix
echo "Home Manager Rebuilding..."
sudo home-manager switch --flake $REPO#$HOST &>home-manager-switch.log || (
    cat home-manager-switch.log | grep --color error && false
)
gen=$(home-manager list-generations | grep current)
git commit -am "$gen"
pop
