{ ... }:

{
  # Host-specific overrides for alpha-1-5 - template imports are handled automatically
  
  # Temporarily disable devenv due to cachix build issues on macOS
  features.cli.devenv.enable = false;
}
