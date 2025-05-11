{ config, lib, ... }:

with lib;
let cfg = config.features.cli.nixvim;
in {
  config = mkIf cfg.enable {
    programs.nixvim = {
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
        undodir = "${config.home.homeDirectory}/.vim/undodir";
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
          };
          register = "unnamedplus";
        };
      };

      extraConfigVim = ''
        set isfname+=@-@
        set iskeyword+=-
      '';
    };
  };
}
