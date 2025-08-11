{ pkgs, inputs, ... }:

{
  tmux-sessionizer = pkgs.callPackage ./tmux-sessionizer {};
  nixvim = pkgs.callPackage ./nixvim { nixvim = inputs.nixvim; };
}
