{ pkgs, ... }:

{
  imports = [ ./mimeApps.nix ./xdg_dirs.nix ];

  xdg.enable = true;
  home.packages = with pkgs; [ xdg-utils ];
}
