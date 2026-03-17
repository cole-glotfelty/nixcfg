{ config, lib, ... }:

with lib;
let
  cfg = config.features.style.colors;
in {
  options.features.style.colors = {
    enable = mkEnableOption (mdDoc ''
      Tokyo Night color palettes (Storm dark + Day light).

      Structure:
      - palette.dark.{bg,fg,red,green,...}
      - palette.light.{bg,fg,red,green,...}

      ANSI colors use the same value for normal/bright except:
      - black vs brightBlack
      - white vs brightWhite

      All colors are hex values without the # prefix.
      Usage: color = "#''${palette.dark.blue}";
    '');

    palette = mkOption {
      type = types.attrs;
      readOnly = true;
      description = mdDoc "Tokyo Night color palettes";
    };
  };

  config = mkIf cfg.enable {
    features.style.colors.palette = {
      # Tokyo Night Storm (dark)
      dark = {
        bg = "24283b";
        bgDark = "1f2335";
        bgDarker = "1b1e2d";
        bgHighlight = "292e42";

        fg = "c0caf5";
        fgDark = "a9b1d6";
        fgGutter = "3b4261";

        selection = "364a82";
        comment = "565f89";
        border = "3b4261";

        # ANSI colors (same for normal and bright)
        black = "1f2335";
        red = "f7768e";
        green = "9ece6a";
        yellow = "e0af68";
        blue = "7aa2f7";
        magenta = "bb9af7";
        cyan = "7dcfff";
        white = "a9b1d6";

        # Bright variants (only where different)
        brightBlack = "414868";
        brightWhite = "c0caf5";

        # Accent colors
        orange = "ff9e64";
        teal = "1abc9c";
        purple = "9d7cd8";
        pink = "ff007c";

        git = {
          add = "449dab";
          change = "6183bb";
          delete = "914c54";
        };
      };

      # Nord Light - complements Tokyo Night's cool tones
      # https://www.nordtheme.com/docs/colors-and-palettes
      light = {
        bg = "eceff4";       # nord6 - Snow Storm lightest
        bgDark = "e5e9f0";   # nord5
        bgDarker = "d8dee9"; # nord4
        bgHighlight = "d8dee9";

        fg = "2e3440";       # nord0 - Polar Night darkest (good contrast!)
        fgDark = "3b4252";   # nord1
        fgGutter = "4c566a"; # nord3

        selection = "d8dee9"; # nord4
        comment = "4c566a";   # nord3
        border = "d8dee9";    # nord4

        # ANSI colors
        black = "3b4252";    # nord1
        red = "bf616a";      # nord11
        green = "a3be8c";    # nord14
        yellow = "ebcb8b";   # nord13
        blue = "5e81ac";     # nord10
        magenta = "b48ead";  # nord15
        cyan = "88c0d0";     # nord8
        white = "e5e9f0";    # nord5

        # Bright variants
        brightBlack = "4c566a";  # nord3
        brightWhite = "eceff4";  # nord6

        # Accent colors (Frost + Aurora)
        orange = "d08770";   # nord12
        teal = "8fbcbb";     # nord7
        purple = "b48ead";   # nord15
        pink = "bf616a";     # nord11

        git = {
          add = "a3be8c";    # nord14 green
          change = "ebcb8b"; # nord13 yellow
          delete = "bf616a"; # nord11 red
        };
      };
    };
  };
}
