#!/usr/bin/env bash
REPO=~/nix
HOST=$1

set -e
pushd $REPO
echo "Starting ..."
# nixfmt . &>/dev/null
git diff -U0 *.nix
echo "Home Manager Rebuilding..."
home-manager switch --flake $REPO#$HOST &>home-manager-switch.log || (
    cat home-manager-switch.log | grep --color error && false
)
gen=$(home-manager generations | grep id -m 1)
git commit -am "$gen"
popd
echo "Done"
