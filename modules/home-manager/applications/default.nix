{ pkgs, ... }:

{
  imports = [
    ./media.nix
    ./messaging.nix
    ./discord
    ./browsers.nix
    ./librewolf.nix
    ./firefox.nix
    ./brave.nix
    ./zen-browser.nix
    ./kitty.nix
    ./alacritty.nix
    ./games.nix
    ./electron.nix
    ./productivity.nix
    ./ghostty.nix
    ./mpd.nix
  ];

  home.packages = with pkgs;
    lib.optionals stdenv.isLinux [ via ];
}
