{ config, lib, ... }:

with lib;
let cfg = config.features.cli.git;
in {
  options.features.cli.git.enable = mkEnableOption "enable git configuration";

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      # TODO: Can I make this dependent on the home configuration it's included in?
      userName = "Cole Glotfelty";
      userEmail = "git@postagepaid.cc";
      aliases = {
        logg =
          "log --graph --pretty=tformat:'%Cred%h %Cgreen%cd %C(bold blue)%an%Creset%C(yellow)%d%Creset %s' --date=short --all";
      };
      extraConfig = {
        init.defaultBranch = "main";
        safe.directory = [
          "/home/${config.home.username}/nixos-config"
          "/home/${config.home.username}/.nixos-config/.git"
          "/home/${config.home.username}/Projects/nixcfg/.git"
          "/home/${config.home.username}/Projects/nixcfg"
        ];
      };
    };
  };
}
