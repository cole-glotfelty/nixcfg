{ lib, pkgs, config, ... }:

with lib;

{
  options.custom.defaults = {
    terminal = mkOption {
      type = types.str;
      default = "kitty";
      description = "Default terminal emulator";
      example = "ghostty";
    };

    browser = mkOption {
      type = types.str;
      default = "firefox";
      description = "Default web browser";
      example = "firefox";
    };

    editor = mkOption {
      type = types.str;
      default = "nvim";
      description = "Default text editor";
      example = "nvim";
    };

    fileManager = mkOption {
      type = types.str;
      default = "ranger";
      description = "Default file manager";
      example = "ranger";
    };

    copyCommand = mkOption {
      type = types.str;
      default = "wl-copy";
      description = "System clipboard copy command";
      example = "pbcopy"; # for macOS
    };

    mailClient = mkOption {
      type = types.str;
      default = config.custom.defaults.browser;
      defaultText = "config.custom.defaults.browser";
      description = "Default mail client (defaults to browser for webmail, can be overridden with dedicated clients)";
      example = "thunderbird";
    };
  };

  config = {
    warnings = 
      # Wayland vs X11 clipboard command warnings
      (optional (pkgs.stdenv.isLinux && config.custom.defaults.copyCommand == "xclip") 
        "copyCommand is set to 'xclip' (X11) but you might be running Wayland. Consider using 'wl-copy' for better compatibility.") ++
      
      (optional (pkgs.stdenv.isLinux && config.custom.defaults.copyCommand == "pbcopy") 
        "copyCommand is set to 'pbcopy' (macOS) but you're on Linux. Use 'wl-copy' for Wayland or 'xclip' for X11.") ++
      
      # macOS vs Linux clipboard command warnings  
      (optional (pkgs.stdenv.isDarwin && elem config.custom.defaults.copyCommand ["wl-copy" "xclip"]) 
        "copyCommand is set to '${config.custom.defaults.copyCommand}' (Linux) but you're on macOS. Use 'pbcopy' instead.");

    assertions = [
      {
        assertion = config.custom.defaults.copyCommand != "";
        message = ''
          custom.defaults.copyCommand must be set for clipboard functionality.
          
          Platform-appropriate options:
            ${optionalString pkgs.stdenv.isLinux "Linux: copyCommand = \"wl-copy\"; # (Wayland) or \"xclip\"; # (X11)"}
            ${optionalString pkgs.stdenv.isDarwin "macOS: copyCommand = \"pbcopy\";"}
        '';
      }
      
      # Validate default values match enabled modules
      {
        assertion = (config.custom.defaults.terminal == "kitty") -> 
                     config.features.applications.kitty.enable;
        message = ''
          You're using the default terminal "kitty" but the kitty module is not enabled.
          
          Fix by either:
            1. Enable the module: features.applications.kitty.enable = true;
            2. Or change to a different terminal: custom.defaults.terminal = "yourChoice";
        '';
      }
      {
        assertion = (config.custom.defaults.browser == "firefox") -> 
                     config.features.applications.browsers.enable;
        message = ''
          You're using the default browser "firefox" but the browsers module is not enabled.
          
          Fix by either:
            1. Enable the module: features.applications.browsers.enable = true;
            2. Or change to a different browser: custom.defaults.browser = "yourChoice";
        '';
      }
    ];
  };
}