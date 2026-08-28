{ pkgs, ... }:

{
  imports = [
    ./zsh.nix
    ./fzf.nix
    ./zoxide.nix
    ./tmux.nix
    ./vim.nix
    ./ranger.nix
    ./git.nix
    ./latex.nix
    ./sshHosts.nix
    ./devenv.nix  # Temporarily disabled due to cachix build issues on macOS
    ./abcde.nix
    ./nixvim
    ./sops.nix
    ./claude-code.nix
    ./rclone.nix
  ];

  # NOTE: You may have to change some of these in the future
  programs.eza = {
    enable = true;
    enableZshIntegration = false; # Disabled to use manual aliases in zsh.nix
    enableBashIntegration = false;
    extraOptions = [ "--icons" "--git" ];
  };

  programs.bat.enable = true;

  home.packages = with pkgs; [
    # Core
    coreutils-full
    ripgrep
    fd
    fzf
    file
    htop
    bottom
    zip
    unzip
    p7zip
    unrar
    wget
    curl
    gdu
    sshfs
    tealdeer
    magic-wormhole
    libqalculate
    fastfetch

    # Applications
    pandoc
    imagemagick
    hugo
    claude-code
    gemini-cli
  ];
}
