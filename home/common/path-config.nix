{ lib, config, ... }:

with lib;

{
  options.custom.paths = {
    projects = mkOption {
      type = types.path;
      default = "${config.custom.user.homeDirectory}/Projects";
      defaultText = "\${config.custom.user.homeDirectory}/Projects";
      description = "Directory containing user projects";
    };

    nixcfg = mkOption {
      type = types.path;
      default = "${config.custom.paths.projects}/nixcfg";
      defaultText = "\${config.custom.paths.projects}/nixcfg";
      description = "Path to nix configuration repository";
    };

    remote = mkOption {
      type = types.path;
      default = "${config.custom.user.homeDirectory}/Remote";
      defaultText = "\${config.custom.user.homeDirectory}/Remote";
      description = "Directory for remote/mounted filesystems";
    };
  };
}