{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.cli.zsh;
in {
  options.features.cli.zsh.enable =
    mkEnableOption "enable extended ZSH configuration";
  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        cmd_duration.disabled = true;
        character = {
          success_symbol = "[>](bold green)";
          error_symbol = "[x](bold red)";
          vimcmd_symbol = "[<](bold green)";
        };

        git_commit.tag_symbol = " tag ";

        git_status = {
          ahead = ">";
          behind = "<";
          diverged = "<>";
          renamed = "r";
          deleted = "x";
        };

        aws.symbol = "aws ";

        azure.symbol = "az ";

        buf.symbol = "buf ";

        bun.symbol = "bun ";

        c.symbol = "C ";

        cpp.symbol = "C++ ";

        cobol.symbol = "cobol ";

        conda.symbol = "conda ";

        container.symbol = "container ";

        crystal.symbol = "cr ";

        cmake.symbol = "cmake ";

        daml.symbol = "daml ";

        dart.symbol = "dart ";

        deno.symbol = "deno ";

        dotnet.symbol = ".NET ";

        directory.read_only = " ro";

        docker_context.symbol = "docker ";

        elixir.symbol = "exs ";

        elm.symbol = "elm ";

        fennel.symbol = "fnl ";

        fossil_branch.symbol = "fossil ";

        gcloud.symbol = "gcp ";

        git_branch.symbol = "git ";

        gleam.symbol = "gleam ";

        golang.symbol = "go ";

        gradle.symbol = "gradle ";

        guix_shell.symbol = "guix ";

        haskell.symbol = "haskell ";

        helm.symbol = "helm ";

        hg_branch.symbol = "hg ";

        java.symbol = "java ";

        julia.symbol = "jl ";

        kotlin.symbol = "kt ";

        lua.symbol = "lua ";

        nodejs.symbol = "nodejs ";

        memory_usage.symbol = "memory ";

        meson.symbol = "meson ";

        nats.symbol = "nats ";

        nim.symbol = "nim ";

        nix_shell.symbol = "nix ";

        ocaml.symbol = "ml ";

        opa.symbol = "opa ";

        os.symbols = {
          AIX = "aix ";
          Alpaquita = "alq ";
          AlmaLinux = "alma ";
          Alpine = "alp ";
          Amazon = "amz ";
          Android = "andr ";
          Arch = "rch ";
          Artix = "atx ";
          Bluefin = "blfn ";
          CachyOS = "cach ";
          CentOS = "cent ";
          Debian = "deb ";
          DragonFly = "dfbsd ";
          Emscripten = "emsc ";
          EndeavourOS = "ndev ";
          Fedora = "fed ";
          FreeBSD = "fbsd ";
          Garuda = "garu ";
          Gentoo = "gent ";
          HardenedBSD = "hbsd ";
          Illumos = "lum ";
          Kali = "kali ";
          Linux = "lnx ";
          Mabox = "mbox ";
          Macos = "mac ";
          Manjaro = "mjo ";
          Mariner = "mrn ";
          MidnightBSD = "mid ";
          Mint = "mint ";
          NetBSD = "nbsd ";
          NixOS = "nix ";
          Nobara = "nbra ";
          OpenBSD = "obsd ";
          OpenCloudOS = "ocos ";
          openEuler = "oeul ";
          openSUSE = "osuse ";
          OracleLinux = "orac ";
          Pop = "pop ";
          Raspbian = "rasp ";
          Redhat = "rhl ";
          RedHatEnterprise = "rhel ";
          RockyLinux = "rky ";
          Redox = "redox ";
          Solus = "sol ";
          SUSE = "suse ";
          Ubuntu = "ubnt ";
          Ultramarine = "ultm ";
          Unknown = "unk ";
          Uos = "uos ";
          Void = "void ";
          Windows = "win ";
        };

        package.symbol = "pkg ";

        perl.symbol = "pl ";

        php.symbol = "php ";

        pijul_channel.symbol = "pijul ";

        pixi.symbol = "pixi ";

        pulumi.symbol = "pulumi ";

        purescript.symbol = "purs ";

        python.symbol = "py ";

        quarto.symbol = "quarto ";

        raku.symbol = "raku ";

        rlang.symbol = "r ";

        ruby.symbol = "rb ";

        rust.symbol = "rs ";

        scala.symbol = "scala ";

        spack.symbol = "spack ";

        solidity.symbol = "solidity ";

        status.symbol = "[x](bold red) ";

        sudo.symbol = "sudo ";

        swift.symbol = "swift ";

        typst.symbol = "typst ";

        terraform.symbol = "terraform ";

        zig.symbol = "zig ";
      };
    };

    programs.zsh = {
      enable = true;
      zprof.enable = false; # If prompt is slow enable to profile
      autocd = true;
      autosuggestion.enable = false;
      syntaxHighlighting.enable = false;
      enableCompletion = true;

      antidote = {
        enable = false;
        plugins = [ "zap-zsh/supercharge" "zap-zsh/atmachine-prompt" ];
      };

      initContent = ''
        # Speeding up zsh launch times
        autoload -Uz compinit
        compinit -C # Use cache, avoids unnecessary compdump

        source ${pkgs.zsh-defer}/share/zsh-defer/zsh-defer.plugin.zsh

        zsh-defer source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        zsh-defer source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh

        # Accept history searched thing
        bindkey '^ ' autosuggest-accept

        # Initialize zoxide with zsh integration
        eval "$(zoxide init zsh --cmd cd)"

        # Some opts taken from zsh/supercharge
        setopt GLOB_DOTS
        setopt MENU_COMPLETE

        # ZSH History stuff
        setopt APPEND_HISTORY
        setopt BANG_HIST
        setopt HIST_EXPIRE_DUPS_FIRST
        setopt HIST_IGNORE_DUPS
        setopt HIST_IGNORE_ALL_DUPS
        setopt HIST_IGNORE_SPACE
        setopt HIST_SAVE_NO_DUPS
        setopt HIST_REDUCE_BLANKS

        # Color man pages
        export MANPAGER="less -R -use-color -Dd+r -Du+b"
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
      # profileExtra = ''
      #   export NIX_PATH=nixpkgs=channel:nixos-unstable
      #   export NIX_LOG=info
      #   export TERMINAL=kitty
      #   export EDITOR=nvim
      # '';

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
