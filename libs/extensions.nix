lib: with lib; rec {
  # Credit goes to Jackson Warhover (@jbwar22) for these
  checkHMOpt = config: testFunc: predicate:
    let
      homeUsers = config.home-manager.users or { };
      userConfigs = lib.attrValues homeUsers;
    in testFunc predicate userConfigs;

  mkIfAnyHMOpt = config: predicate:
    lib.mkIf (checkHMOpt config lib.any predicate);

  mkIfAllHMOpt = config: predicate:
    lib.mkIf (checkHMOpt config lib.all predicate);

  filterFromDir = dir: typepredicate: filepredicate:
    pipe (builtins.readDir dir) [
      (filterAttrs (file: type: typepredicate type && filepredicate file))
      (mapAttrsToList (file: _: dir + "/${file}"))
    ];
  getDirsFilter = dir: filepredicate:
    filterFromDir dir (type: type == "directory") filepredicate;
  getDirs = dir: getDirsFilter dir (_: true);
  getFilesFilter = dir: filepredicate:
    filterFromDir dir (type: type != "directory") filepredicate;
  getFiles = dir: getFilesFilter dir (_: true);

  getDir = dir:
    mapAttrs
    (file: type: if type == "directory" then getDir "${dir}/${file}" else type)
    readDir dir;

  # Dynamic system user imports from user templates based on host metadata
  # mkSystemUserImports = config: userTemplatesPath: hostsPath:
  #   let
  #     hostName = config.networking.hostName;
  #     hostConfig =
  #       import (hostsPath + "/${hostName}/default.nix") { lib = final; };
  #     hostMeta = hostConfig._meta or { users = [ ]; };
  #
  #     # Only import system configs for users that:
  #     # 1. Are declared in host metadata (_meta.users)
  #     # 2. Have a host-specific config file (hosts/{hostname}/users/{user}.nix)
  #     # 3. Have a system template (users/templates/{user}/system.nix)
  #     validUsers = builtins.filter (user:
  #       let
  #         hostUserConfig = hostsPath + "/${hostName}/users/${user}.nix";
  #         systemTemplate = userTemplatesPath + "/${user}/system.nix";
  #       in builtins.pathExists hostUserConfig
  #       && builtins.pathExists systemTemplate) hostMeta.users;
  #
  #     systemUserModules =
  #       map (user: userTemplatesPath + "/${user}/system.nix") validUsers;
  #   in systemUserModules;

}
