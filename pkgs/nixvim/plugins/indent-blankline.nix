# Standalone nixvim indent-blankline configuration
# Extracted from home/features/cli/nixvim/plugins/indent-blankline.nix
{ ... }:

{
  plugins.indent-blankline = {
    enable = true;
    settings = {
      indent = { char = "┊"; };
      whitespace = { remove_blankline_trail = true; };
      scope = { enabled = false; };
      exclude = {
        buftypes = [ "terminal" "nofile" ];
        filetypes = [
          "help"
          "startify"
          "dashboard"
          "packer"
          "neogitstatus"
          "Trouble"
        ];
      };
    };
  };
}