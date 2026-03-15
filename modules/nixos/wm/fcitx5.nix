{ config, lib, pkgs, inputs, ... }:

with lib;
let
  cfg = config.features.wm.fcitx5;
  ori-theme = pkgs.linkFarm "fcitx5-ori-theme" {
    "share/fcitx5/themes/OriDark" = "${inputs.fcitx5-ori-theme}/OriDark";
    "share/fcitx5/themes/OriLight" = "${inputs.fcitx5-ori-theme}/OriLight";
  };
in {
  options.features.wm.fcitx5.enable = mkEnableOption "enable input via fcitx5";

  config = mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-gtk
          fcitx5-mozc
          qt6Packages.fcitx5-chinese-addons
          ori-theme
        ];
        ignoreUserConfig = true;
        settings = {
          inputMethod = {
            "Groups/0" = {
              "Name" = "Default";
              "Default Layout" = "us";
              "DefaultIM" = "pinyin";
            };
            "Groups/0/Items/0" = { "Name" = "keyboard-us"; "Layout" = ""; };
            "Groups/0/Items/1" = { "Name" = "pinyin";      "Layout" = "us"; };
            "Groups/0/Items/2" = { "Name" = "mozc";        "Layout" = "us"; };
            "GroupOrder" = { "0" = "Default"; };
          };
          globalOptions = {
            # EnumerateWithTriggerKeys enables cycling through all IMs with Super+space
            "Hotkey"               = { "EnumerateWithTriggerKeys" = true; };
            "Hotkey/TriggerKeys"   = { "0" = "Super+space"; };
            "Hotkey/AltTriggerKeys" = { };
            "Hotkey/PrevPage"      = { "0" = "Up"; };
            "Hotkey/NextPage"      = { "0" = "Down"; };
            "Hotkey/PrevCandidate" = { "0" = "Shift+Tab"; };
            "Hotkey/NextCandidate" = { "0" = "Tab"; };
            "Hotkey/TogglePreedit" = { "0" = "Control+Alt+P"; };
            "Behavior"                = { "CompactInputMethodInformation" = true; };
            "Behavior/DisabledAddons" = { "0" = "notificationitem"; "1" = "cloudpinyin"; };
          };
          # Classic UI addon settings for tray icon appearance
          addons.classicui.globalSection = {
            "Vertical Candidate List"     = false;
            "ShowLayoutNameWhenSwitching" = true;
            "Theme"                       = "OriDark";
          };
        };
      };
    };
  };
}
