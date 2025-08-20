{ ... }:

{
  imports = [
    ./bluetooth.nix
    ./zenKernel.nix
    ./QMKKeyboard.nix
    ./opengl.nix
    ./printing.nix
    ./udisks2.nix
	./nvidia.nix
    ./intel.nix
  ];
}
