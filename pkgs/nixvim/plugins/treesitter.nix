# Standalone nixvim treesitter configuration
# Extracted from home/features/cli/nixvim/plugins/treesitter.nix
{ pkgs, ... }:

{
  plugins.treesitter = {
    enable = true;

    # Install grammars via Nix (read-only, immutable)
    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      python
      cpp
      c
      lua
      vim
      vimdoc
      yaml
      toml
      rust
      nix
      erlang
    ];

    settings = {
      auto_install = false;  # Disable runtime installation (would fail on read-only Nix store)
      sync_install = false;
      highlight = {
        enable = true;
        additional_vim_regex_highlighting = false;
      };
      indent = {
        enable = true;
        disable = [ "python" ];
      };
    };
  };

  plugins.treesitter-textobjects = {
    enable = false;
    settings = {
      select = {
        enable = true;
        lookahead = true;
        keymaps = {
          "aa" = "@parameter.outer";
          "ia" = "@parameter.inner";
          "af" = "@function.outer";
          "if" = "@function.inner";
          "ac" = "@class.outer";
          "ic" = "@class.inner";
          "ii" = "@conditional.inner";
          "ai" = "@conditional.outer";
          "il" = "@loop.inner";
          "al" = "@loop.outer";
          "at" = "@comment.outer";
        };
      };
      move = {
        enable = true;
        goto_next_start = {
          "]m" = "@function.outer";
          "]]" = "@class.outer";
        };
        goto_next_end = {
          "]M" = "@function.outer";
          "][" = "@class.outer";
        };
        goto_previous_start = {
          "[m" = "@function.outer";
          "[[" = "@class.outer";
        };
        goto_previous_end = {
          "[M" = "@function.outer";
          "[]" = "@class.outer";
        };
      };
      swap = {
        enable = true;
        swap_next = { "<leader>a" = "@parameters.inner"; };
        swap_previous = { "<leader>A" = "@parameter.outer"; };
      };
    };
  };
}