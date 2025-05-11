#!/usr/bin/env bash
# Adapted from @0atman

set -e 

# cd to flake directory
if [[ $OSTYPE == "linux-gnu" ]]; then
    pushd ~/Projects/nixcfg
elif [[ $OSTYPE == "darwin"* ]]; then
    pushd ~/Git/nixos-config
fi

# Early return if no changes were detected (thanks @singiamtel!)
# if git diff --quiet '*.nix'; then
#     echo "No changes detected, exiting."
#     popd
#     exit 0
# fi

# Display changes
git diff -U0 '*.nix'

echo "NixOS Rebuilding..."

# Rebuild, output simplified errors, log trackebacks
if [[ $OSTYPE == "linux-gnu" ]]; then
    sudo nixos-rebuild switch --flake . &>nixos-switch.log || (cat nixos-switch.log | grep --color error && exit 1)
elif [[ $OSTYPE == "darwin"* ]]; then
    darwin-rebuild switch --flake . &>darwin-switch.log || (cat darwin-switch.log | grep --color error && exit 1)
fi

# Get current generation metadata
if [[ $OSTYPE == "linux-gnu" ]]; then
    current=$(nixos-rebuild list-generations | grep current)
fi

# Commit all changes witih the generation metadata
if [[ $OSTYPE == "linux-gnu" ]]; then
    git commit -am "$current"
fi

# Back to where you were
popd
