{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.applications.productivity;
in {
  options.features.applications.productivity.enable =
    mkEnableOption "enable productivity applications";
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      obsidian
      libreoffice
    ];

    # LibreOffice: Configure manually for dark UI with white document background
    # 1. Open LibreOffice
    # 2. Go to Tools > Options > LibreOffice > Application Colors
    # 3. Uncheck "Use automatic color for Document background" checkbox
    # 4. Set "Document background" color to white
    # 5. Click OK
    # The UI will use your dark theme but documents will have white backgrounds
  };
}
