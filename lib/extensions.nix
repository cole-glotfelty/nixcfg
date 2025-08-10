final: {
  checkHMOpt = config: testFunc: predicate:
    let
      homeUsers = config.home-manager.users or {};
      userConfigs = final.attrValues homeUsers;
    in testFunc predicate userConfigs;
    
  mkIfAnyHMOpt = config: predicate: 
    final.mkIf (final.checkHMOpt config final.any predicate);
      
  mkIfAllHMOpt = config: predicate:
    final.mkIf (final.checkHMOpt config final.all predicate);
}