# Standalone nixvim options configuration
# Extracted from home/features/cli/nixvim/options.nix
{ ... }:

{
  # Leader Keys
  globals = {
    mapleader = " ";
    maplocalleader = " ";
    have_nerd_font = true;
  };

  opts = {
    # Relative Line Numbers
    number = true;
    relativenumber = true;

    # Tab Stuff
    tabstop = 4;
    softtabstop = 4;
    shiftwidth = 4;
    expandtab = true;
    smartindent = true;

    cursorline = true;
    wrap = false;
    swapfile = false;
    undodir = { __raw = "vim.fn.expand('~') .. '/.vim/undodir'"; };
    backup = false;
    undofile = true;

    hlsearch = false;
    incsearch = true;
    termguicolors = true;
    scrolloff = 8;
    signcolumn = "yes";
    updatetime = 50;

    # enable copy/paste
    clipboard = {
      providers = {
        wl-copy.enable = true; # Wayland
        xsel.enable = true; # For X11
        pbcopy.enable = true; # macOS
      };
      register = "unnamedplus";
    };
  };

  extraConfigVim = ''
    set isfname+=@-@
    set iskeyword+=-
  '';
}