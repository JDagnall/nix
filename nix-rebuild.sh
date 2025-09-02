#!/usr/bin/env bash
REPO=/home/james/nix
HOST=$1
if [[ -n "${HOST}" ]]; then
    HOST=$(hostname)
fi

pushd $REPO
set -e
echo "Starting ..."
# nixfmt . &>/dev/null
git pull
git add .
# git diff -U0 *.nix HEAD
nh os switch -H $HOST --ask
gen="$HOST: $(nh os info | grep true | awk '{print "gen: " $1 " version: " $5}')"
git commit -am "$HOST | $gen | $(date)"
git push
popd
