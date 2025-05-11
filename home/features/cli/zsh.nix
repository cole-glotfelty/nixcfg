{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.cli.zsh;
in {
  options.features.cli.zsh.enable =
    mkEnableOption "enable extended ZSH configuration";
  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;

      antidote = {
        enable = true;
        plugins = [ "zap-zsh/supercharge" "zap-zsh/atmachine-prompt" ];
      };

      initContent = ''
        bindkey '^ ' autosuggest-accept

        # Initialize zoxide with zsh integration
        eval "$(zoxide init zsh --cmd cd)"
      '';

      history = {
        size = 1000000;
        save = 1000000;
      };

      shellAliases = {
        "..." = "cd ../..";
        ls = "${pkgs.eza}/bin/eza --icons";
        ll = "${pkgs.eza}/bin/eza -l --icons";
        la = "${pkgs.eza}/bin/eza -la --icons";
        tree = "${pkgs.eza}/bin/eza -T --icons";
        cat = "${pkgs.bat}/bin/bat";
      };

      # TODO: Declare these here or in home sessionVars?
      profileExtra = ''
        # export NIX_PATH=nixpkgs=channel:nixos-unstable
        # export NIX_LOG=info
        # export TERMINAL=kitty
        # export EDITOR=nvim
      '';

      # NOTE: This is specific to hyprland. also, this will need to be tested
      loginExtra = ''
        if [[ $(tty) == "/dev/tty1" ]]; then
          exec Hyprland &> /dev/null
        fi

        # if uwsm check may-start; then
        #   exec uwsm start hyprland-uwsm.desktop
        # fi

        # if uwsm check may-start && uwsm select; then
        #   exec systemd-cat -t uwsm_start uwsm start default
        # fi
      '';
    };
  };
}
