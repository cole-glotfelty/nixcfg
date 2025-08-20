{ lib, config, ... }:

{
  imports = [
    ./home.nix
    ../../common
    ../../../modules/home-manager/applications
    ../../../modules/home-manager/cli
    ../../../modules/home-manager/desktop
    ../../../modules/home-manager/style
    ../../../modules/home-manager/xdg
  ];
  # Host-specific overrides are automatically included by the flake

  features = {
    cli = {
      zsh.enable = lib.mkDefault true;
      fzf.enable = lib.mkDefault true;
      zoxide.enable = lib.mkDefault true;
      tmux.enable = lib.mkDefault true;
      latex.enable = lib.mkDefault true;
      vim.enable = lib.mkDefault false;
      nixvim.enable = lib.mkDefault true;
      git.enable = lib.mkDefault true;
      ranger.enable = lib.mkDefault true;
      sshHosts.enable = lib.mkDefault true;
      devenv.enable = lib.mkDefault true;
      abcde.enable = lib.mkDefault true;
      sops.enable = lib.mkDefault false;
    };

    desktop = {
      wayland.enable = lib.mkDefault true;
      fuzzel.enable = lib.mkDefault true;
      hyprland.enable = lib.mkDefault true;
      waybar.enable = lib.mkDefault true;
      udiskie.enable = lib.mkDefault true;
      notifications.enable = lib.mkDefault true;
      defaultFonts.enable = lib.mkDefault true;
    };

    style = {
      darkmode.enable = lib.mkDefault true;
    };

    xdg = {
      mimeApps.enable = lib.mkDefault true;
      xdg_dirs.enable = lib.mkDefault true;
    };

    applications = {
      media.enable = lib.mkDefault true;
      messaging.enable = lib.mkDefault true;
      browsers.enable = lib.mkDefault true;
      electronTweaks.enable = lib.mkDefault true;
      productivity.enable = lib.mkDefault true;
      games.enable = lib.mkDefault true;
      kitty.enable = lib.mkDefault true;
      ghostty.enable = lib.mkDefault true;
      alacritty.enable = lib.mkDefault false;
    };
  };
}
