{ lib, config, ... }:

with lib;

{
  options.custom.user = {
    name = mkOption {
      type = types.str;
      default = "User";
      description = "Full name used in applications like git";
      example = "John Doe";
    };

    email = mkOption {
      type = types.str;
      default = "user@example.com";
      description = "Email address for git and other applications";
      example = "john.doe@example.com";
    };

    # These automatically use Home Manager's built-in values
    username = mkOption {
      type = types.str;
      default = config.home.username;
      readOnly = true;
      description = "System username (automatically derived from home.username)";
    };

    homeDirectory = mkOption {
      type = types.path;
      default = config.home.homeDirectory;
      readOnly = true;
      description = "User's home directory path (automatically derived from home.homeDirectory)";
    };
  };
}