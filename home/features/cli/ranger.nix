{ config, lib, ... }:

with lib;
let cfg = config.features.cli.ranger;
in {
  options.features.cli.ranger = {
    enable = mkEnableOption (lib.mdDoc ''
      Ranger terminal file manager with image preview capabilities.
      
      Features:
      - Vi-style keybindings for efficient file navigation
      - Image preview using kitty protocol (compatible with Kitty and Ghostty terminals)
      - Directory tree navigation with file operations
      - Built-in file preview for text files and images
      
      Integrates with: Kitty terminal, Ghostty terminal, custom.defaults.fileManager  
      Requires: Terminal with kitty protocol support for image previews
    '');
  };

  config = mkIf cfg.enable {
    programs.ranger = {
      enable = true;
      settings = {
        preview_images = mkDefault true;
        # Use kitty protocol (works with kitty and ghostty)
        preview_images_method = mkDefault "kitty";
      };
    };
  };
}
