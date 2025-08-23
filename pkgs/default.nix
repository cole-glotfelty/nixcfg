{ pkgs, inputs, ... }:

{
  tmux-sessionizer = pkgs.callPackage ./tmux-sessionizer {};
  nixvim = pkgs.callPackage ./nixvim { nixvim = inputs.nixvim; };
  apple-color-emoji = pkgs.callPackage ./apple-color-emoji { inherit (inputs) apple-emoji; };
}
