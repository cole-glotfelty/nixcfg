{ lib, config, ... }:

{
  imports = [
    ../../common
    ../../features/applications
    ../../features/cli
    ../../features/desktop
    ../../features/style
    ../../features/xdg
    ./home.nix
  ];

  custom.hostname = "melchior";

  features = {
    cli = {
      zsh.enable = true;
      fzf.enable = true;
      zoxide.enable = true;
      tmux.enable = true;
      latex.enable = true;
      vim.enable = true;
      nixvim.enable = true;
      git.enable = true;
      ranger.enable = true;
      sshHosts.enable = true;
      devenv.enable = true;
      abcde.enable = true;
    };

    # TODO: do I need blueman and blueman applet?
    desktop = {
      # TODO: no wayland module here just WM/Compositors or maybe rename to waylandUtils
      wayland.enable = true;
      fuzzel.enable = true;
      hyprland.enable = true;
      waybar.enable = true;
      udiskie.enable = true;
      notifications.enable = true;
      defaultFonts.enable = true;
    };

    # TODO: options for applications and app set theming (fonts and colors, etc)
    # TODO: Maybe make a string option to select color schemes/theming?

    style = {
      # nix-colors. enable = true;
      darkmode.enable = true;
    };

    xdg = {
      mimeApps.enable = true;
      xdg_dirs.enable = true;
    };

    applications = {
      media.enable = true;
      messaging.enable = true;
      browsers.enable = true;
      electronTweaks.enable = true;
      productivity.enable = true;
      games.enable = true;
      kitty.enable = true;
      ghostty.enable = true;
      alacritty.enable = false;
    };
  };

  # TODO: make this dependent on hyprland option being enabled
  wayland.windowManager.hyprland = lib.mkIf config.features.desktop.hyprland.enable {
    settings = { monitor = [ "DP-1,2560x1440@154.85,auto,auto" "DP-4,1920x1080@60,auto,auto" ]; };
  };
}
