{ ... }:

{
  imports = [
    ../../common/options.nix
    ../../features/cli
    ../../features/applications
    ./home.nix
  ];

  custom.hostname = "alpha-1-5";

  features = {
    cli = {
      zsh.enable = true;
      fzf.enable = true;
      git.enable = true;
      tmux.enable = true;
      zoxide.enable = true;
      nixvim.enable = true;
      devenv.enable = true;
    };

    applications = {
      kitty.enable = true;
    };
  };
}
