{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.style.darkmode;
in {
  options.features.style.darkmode.enable = mkEnableOption "enable darkmode";

  # TODO: Select matching GTK/QT Theme and Icons 
  config = mkIf cfg.enable {

    gtk = {
      enable = true;
      gtk3.extraConfig = { gtk-application-prefer-dark-theme = true; };
      gtk4.extraConfig = { gtk-application-prefer-dark-theme = true; };
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
        # package = pkgs.adwaita-icon-theme;
      };
      iconTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
      };
      cursorTheme = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
        size = 24;
      };
    };

    # Qt theme settings to match GTK
    qt = {
      enable = true;
      platformTheme.name = "adwaita";
      # platformTheme = "gtk";
      style = {
        name = "adwaita-dark";
        package = pkgs.adwaita-qt;
      };
    };

    # TODO: are these envrinment variables necssisary?
    # TDOO: check if these should be in hyprland home config
    home.sessionVariables = mkIf cfg.enable {
      # General dark mode preference
      GTK_THEME = "Adwaita:dark";
      # For applications that support the color scheme preference
      THEME_PREFERENCE = "dark";
      # Specifically for apps that check this variable
      COLOR_SCHEME = "prefer-dark";
      # For QT applications
      QT_STYLE_OVERRIDE = "adwaita-dark";
    };

    # Ensure dconf is configured for dark mode
    dconf.settings = mkIf cfg.enable {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "Adwaita-dark";
      };
    };
  };
}
