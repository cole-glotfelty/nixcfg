{ config, lib, ... }:

with lib;
let cfg = config.features.cli.nixvim;
in {
  config = mkIf cfg.enable {
    programs.nixvim.plugins = {
      luasnip.enable = true;
      friendly-snippets.enable = true;
      cmp-nvim-lsp.enable = true;
      cmp-buffer.enable = true;
      cmp-path.enable = true;
      cmp-nvim-lua.enable = true;
      cmp-vimtex.enable = true;
      cmp-nvim-lsp-signature-help.enable = true;
      # lsp-format.enable = true; # formats on save

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings.sources = [
          { name = "nvim_lsp"; }
          { name = "nixpkgs_maintainers"; }
          { name = "path"; }
          { name = "nvim_lsp_signature_help"; }
          { name = "nvim_lua"; }
          {
            name = "buffer";
            keyword_length = 3;
          }
          {
            name = "luasnip";
            keyword_length = 2;
          }
        ];
        settings.mapping = {
          "<CR>" = "cmp.mapping.confirm({select = false})";
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-k>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<C-j>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          "<C-y>" = "cmp.mapping.confirm({select = false})";

        };
      };
      none-ls = {
        enable = true;
        # TODO: Set this up
        # enableLspFormat = true;
        sources = {
          formatting = {
            clang_format.enable = true;
            nixfmt.enable = true;
            markdownlint.enable = true;
            shellharden.enable = true;
            black.enable = true;
            google_java_format.enable = true;
          };
        };
      };
    };
  };
}
