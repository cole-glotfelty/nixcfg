{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.features.cli.git;
  # Tokyo Night Storm palette (same convention as tmux.nix).
  c = config.features.style.colors.palette.dark;
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

    # Delta pager: syntax-highlighted diffs with a Tokyo Night Storm theme.
    # `navigate` enables n/N to jump between files. Top-level programs.delta
    # (not programs.git.delta) is the current home-manager option.
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        syntax-theme = "ansi";
        dark = true;
        keep-plus-minus-markers = true;
        navigate = true;
        line-numbers = true;
        line-numbers-left-format = "";
        line-numbers-right-format = "{np:>5}";
        line-numbers-left-style = "#${c.fgDark}";
        line-numbers-right-style = "#${c.fgDark}";
        line-numbers-zero-style = "#${c.fgDark}";
        line-numbers-plus-style = "#${c.fgDark} #365846";
        line-numbers-minus-style = "#${c.fgDark} #603844";
        plus-style = "#b9e987 #365846";
        plus-non-emph-style = "#b9e987 #365846";
        plus-emph-style = "bold #d0f5a4 #48735a";
        minus-style = "#ff899d #603844";
        minus-non-emph-style = "#ff899d #603844";
        minus-emph-style = "bold #ffb0bd #7a4655";
        file-modified-label = "modified:";
        file-style = "bold #${c.fg} #3d59a1";
        file-decoration-style = "#${c.blue} box";
        hunk-header-style = "file line-number syntax #343a52";
        hunk-header-file-style = "bold #${c.blue}";
        hunk-header-line-number-style = "bold #${c.magenta}";
        hunk-header-decoration-style = "#${c.comment} box";
      };
    };

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
