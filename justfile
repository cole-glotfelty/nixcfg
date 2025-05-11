# TODO: Update this for nixos only
# https://discourse.nixos.org/t/detect-that-bash-script-is-running-under-nixos/11402/3
rebuild:
    ./scripts/rebuild.sh

update:
    nix flake update
    just rebuild

gc:
    sudo nix-collect-garbage --delete-old
