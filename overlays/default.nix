{ inputs, ... }:

{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; inherit inputs; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev:
    {
      # Hyprland's new Lua config manager (0.55+) changed the hyprctl IPC
      # dispatch wire format, breaking workspace-button clicks in Waybar
      # 0.15.0 (nixpkgs' current release predates the fix). Build from a
      # post-fix master commit until a release ships it.
      # Upstream: https://github.com/Alexays/Waybar/issues/5008
      #
      # TODO: on next `nix flake update`, check whether nixpkgs' waybar
      # version has moved past 0.15.0 (`nix eval .#nixpkgs.waybar.version`
      # or just check pkgs.waybar.version) and contains the fix for the
      # above issue. If so, drop this whole override (including the
      # cavaSupport, wwan, and tests-disabled workarounds below, which
      # only exist because we build from a Waybar master commit).
      waybar = (prev.waybar.override {
        # nixpkgs vendors a cava subproject pinned to 0.10.7-beta; this
        # master commit now requires libcava >=1.0.0, so the vendored
        # subproject no longer satisfies meson's version check. We don't
        # use the cava (audio visualizer) module, so just drop it.
        cavaSupport = false;
      }).overrideAttrs (oldAttrs: {
        version = "unstable-2026-08-27";
        src = prev.fetchFromGitHub {
          owner = "Alexays";
          repo = "Waybar";
          rev = "6d60c8e02be67bb85bb9b1ea803f2fbcf0722002";
          hash = "sha256-G6AcGuevhkYflQHhJq9GnLhEMgcI51Y6MYKBQvdRPDc=";
        };
        # New "wwan" (ModemManager) module landed on master without a
        # matching build input in the 0.15.0-era package; we don't need it.
        # waybar:utils' sleeper_thread test forks a real subprocess to
        # check thread-stop behavior under concurrent signals; that fails
        # in the Nix build sandbox (no working /bin/sh for it to exec),
        # not an actual regression in waybar's code -- disable the test
        # target entirely (doCheck alone just drops catch2 from the
        # build inputs while meson still tries to configure it).
        mesonFlags = (final.lib.filter
          (f: !(final.lib.hasPrefix "-Dtests=" f)) oldAttrs.mesonFlags)
          ++ [ "-Dwwan=disabled" "-Dtests=disabled" ];
        doInstallCheck = false;
        doCheck = false;
      });
    };

  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}
