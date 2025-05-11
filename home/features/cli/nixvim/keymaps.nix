{ config, lib, ... }:

with lib;
let cfg = config.features.cli.nixvim;
in {
  config = mkIf cfg.enable {
    programs.nixvim = {
      keymaps = [
        {
          mode = "v";
          key = "J";
          action = ":m '>+1<CR>gv=gv";
          options.desc = "Shift selected test down";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "v";
          key = "K";
          action = ":m '<-2<CR>gv=gv";
          options.desc = "Shift selected test up";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "n";
          key = "J";
          action = "mzJ`z";
          options.desc = "Join line with line below";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "n";
          key = "<C-d>";
          action = "<C-d>zz";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "n";
          key = "<C-u>";
          action = "<C-u>zz";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "n";
          key = "n";
          action = "nzzzv";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "n";
          key = "N";
          action = "Nzzzv";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "v";
          key = "<";
          action = "<gv";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "v";
          key = ">";
          action = ">gv";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "n";
          key = "<C-Up";
          action = ":resize -2<CR>";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "n";
          key = "<C-Down";
          action = ":resize +2<CR>";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "n";
          key = "<C-Left";
          action = ":vertical resize -2<CR>";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "n";
          key = "<C-Right";
          action = ":vertical resize +2<CR>";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "n";
          key = "<S-l>";
          action = ":bnext<CR>";
          options.desc = "Next buffer";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "n";
          key = "<S-h>";
          action = ":bprevious<CR>";
          options.desc = "Previous buffer";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "x";
          key = "<leader>p";
          action = ''"_dP''; # is this how to escape the inner quote
          options.desc = "Paste over line";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = [ "n" "v" ]; # this seems like voodoo
          key = "<leader>y";
          action = ''"+y''; # is this how to escape the inner quote
          options.desc = "Copy to system clipboard";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "n";
          key = "<leader>Y";
          action = ''"+Y''; # is this how to escape the inner quote
          options.desc = "Copy to system clipboard";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = [ "n" "v" ]; # this seems like voodoo
          key = "<leader>d";
          action = ''"_d''; # is this how to escape the inner quote
          options.desc = "Delete and send to void";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "i";
          key = "<C-c>";
          action = "<Esc>";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "n";
          key = "Q";
          action = "<nop>";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "n";
          key = "<C-f>";
          action = "<cmd>silent !tmux neww tmux-sessionizer<CR>";
          options.desc = "Create new tmux session";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "n";
          key = "<leader>s";
          action = ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>";
          options.desc = "Find and replace all";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "n";
          key = "<leader>x";
          action = "<cmd>!chmod +x %<CR>";
          options.desc = "Make executable";
          options.silent = true;
        }

        {
          mode = [ "n" "v" ]; # this seems like voodoo
          key = "<space>";
          action = "<nop>";
          options.silent = true;
        }

        {
          mode = "n";
          key = "<leader>e";
          action = ":Ex<CR>";
          options.desc = "File browser";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "n";
          key = "<leader>u";
          action = ":UndotreeToggle<CR>";
          options.desc = "Undo tree";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "n";
          key = "<leader>bc";
          action = ":Bd<CR>";
          options.desc = "Close buffer";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "n";
          key = "<leader>c";
          action = ''
            :execute "set colorcolumn=" . (&colorcolumn == "" ? "81" : "")<CR>'';
          options.desc = "Hide/Show 80 Line Column";
          options.noremap = true;
          options.silent = true;
        }

        {
          mode = "n";
          key = "<leader>cs";
          action = ''
            :CloakPreviewLine<CR>'';
          options.desc = "(cloak) preview the current line of sensitive files";
          options.noremap = true;
          options.silent = true;
        }
      ];
    };
  };
}
