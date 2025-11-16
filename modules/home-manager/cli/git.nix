{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.cli.git;
in {
  options.features.cli.git = {
    enable = mkEnableOption (lib.mdDoc ''
      Git version control with user identity and repository configuration.

      Features:
      - User identity automatically sourced from custom.user.name/email
      - Enhanced log alias with graph, colors, and commit info
      - Default branch set to 'main' following modern conventions
      - Safe directory configuration for nixcfg repository access

      Dependencies: custom.user (name, email), custom.paths.nixcfg
    '');
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.custom.user.name != "" && config.custom.user.name
          != "User";
        message = ''
          Git module requires a real user name to be configured.

          Current value: '${config.custom.user.name}'

          Fix by adding to your configuration:
            custom.user.name = "Your Full Name";
        '';
      }
      {
        assertion = config.custom.user.email != "" && config.custom.user.email
          != "user@example.com";
        message = ''
          Git module requires a real email address to be configured.

          Current value: '${config.custom.user.email}'

          Fix by adding to your configuration:
            custom.user.email = "you@example.com";
        '';
      }
    ];

    home.packages = with pkgs; [ gh ];

    programs.git = {
      enable = true;
      settings = {
        user = {
          name = mkDefault config.custom.user.name;
          email = mkDefault config.custom.user.email;
        };
        alias = {
          logg =
            "log --graph --pretty=tformat:'%Cred%h %Cgreen%cd %C(bold blue)%an%Creset%C(yellow)%d%Creset %s' --date=short --all";
        };
        init.defaultBranch = mkDefault "main";
        safe.directory =
          [ config.custom.paths.nixcfg "${config.custom.paths.nixcfg}/.git" ];
      };
    };
  };
}
