{ inputs, ... }:

{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev:
    {
      # example = prev.example.overrideAttrs (oldAttrs: rec {
      # ...
      # });
    };

  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  dwarf-fortress = final: prev: {
    dwarf-fortress-packages.dwarf-fortress-full =
      prev.dwarf-fortress-packages.dwarf-fortress-full.overrideAttrs
      (oldAttrs: rec {
        installPhase = ''
          # Create directories for tileset and initialization files
          mkdir -p $out/share/df_linux/data/art
          cp /path/to/your/wanderlust.png $out/share/df_linux/data/art/Wanderlust.png
          mkdir -p $out/share/df_linux/data/init

          # Modify init file to use Wanderlust tileset
          sed -i 's/FONT:curses_640x300.png/FONT:Wanderlust.png/' $out/share/df_linux/data/init/init_default.txt
          sed -i 's/FULLFONT:curses_640x300.png/FULLFONT:Wanderlust.png/' $out/share/df_linux/data/init/init_default.txt
          sed -i 's/BASIC_FONT:curses_640x300.png/BASIC_FONT:Wanderlust.png/' $out/share/df_linux/data/init/init_default.txt
        '';
      });
  };
}
