# Standalone nixvim plugins configuration
# Extracted from home/features/cli/nixvim/plugins/default.nix
{ pkgs, ... }:

{
  imports = [
    ./telescope.nix
    ./treesitter.nix
    ./lsp.nix
    ./cmp.nix
    ./gitsigns.nix
    ./indent-blankline.nix
    ./vimtex.nix
    ./cloak.nix
    ./autoclose.nix
  ];

  plugins = {
    bufferline.enable = true;
    fugitive.enable = true;
    undotree.enable = true;
    vim-bbye.enable = true;
    comment.enable = true;
    todo-comments.enable = true;
    nix.enable = true;
    web-devicons.enable = true;
  };

  extraPlugins = with pkgs.vimPlugins; [
    neodev-nvim
    (pkgs.vimUtils.buildVimPlugin {
      pname = "erlang-skeletons";
      version = "2024-02-20";
      src = pkgs.fetchFromGitHub {
        owner = "EliasA5";
        repo = "erlang-skeletons";
        rev = "e117222abaf863258617a1804c0c9c1a49f70d7b";
        sha256 = "sha256-g18guEJW5/VSwo5ApS7gKawWjz/rd3zewYyz6d/OJCg=";
      };
    })
  ];

  extraConfigLua = ''
    require("neodev").setup()
    require('erlang-skeletons').setup()
  '';
}