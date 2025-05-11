{ config, lib, pkgs, ... }:

with lib;
let cfg = config.features.wm.fcitx5;
in {
  options.features.wm.fcitx5.enable = mkEnableOption "enable input via fcitx5";

  # TODO: Why is the locations of the nofier for inputMethod always in a random spot
  # TODO: Theme the prompt window (home module? or will that not work)
  config = mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {

        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-gtk
          fcitx5-skk-qt
          fcitx5-rime
          fcitx5-chinese-addons
        ];
        ignoreUserConfig = true;
        settings = {
          inputMethod = {
            "Groups/0" = {
              "Name" = "Default";
              "Default Layout" = "us";
              "DefaultIM" = "pinyin";
            };

            "Groups/0/Items/0" = {
              "Name" = "keyboard-us";
              "Layout" = "";
            };

            "Groups/0/Items/1" = {
              "Name" = "pinyin";
              "Layout" = "us";
            };

            "GroupOrder" = { "0" = "Default"; };
          };
          globalOptions = {
            "Hotkey" = {
              "EnumerateWithTriggerKeys" = true;
              "EnumerateForwardKeys" = "";
              "EnumerateBackwardKeys" = "";
              "EnumerateSkipFirst" = false;
              "EnumerateGroupForwardKeys" = "";
              "EnumerateGroupBackwardKeys" = "";
            };

            "Hotkey/TriggerKeys" = {
              "0" = "Super+space";
              "1" = "Zenkaku_Hankaku";
              "2" = "Hangul";
            };

            "Hotkey/AltTriggerKeys" = { "0" = "Shift_L"; };

            "Hotkey/ActivateKeys" = { "0" = "Hangul_Hanja"; };

            "Hotkey/DeactivateKeys" = { "0" = "Hangul_Romaja"; };

            "Hotkey/PrevPage" = { "0" = "Up"; };

            "Hotkey/NextPage" = { "0" = "Down"; };

            "Hotkey/PrevCandidate" = { "0" = "Shift+Tab"; };

            "Hotkey/NextCandidate" = { "0" = "Tab"; };

            "Hotkey/TogglePreedit" = { "0" = "Control+Alt+P"; };

            "Behavior" = {
              "ActiveByDefault" = false;
              "resetStateWhenFocusIn" = "No";
              "ShareInputState" = "No";
              "PreeditEnabledByDefault" = true;
              "ShowInputMethodInformation" = true;
              "showInputMethodInformationWhenFocusIn" = false;
              "CompactInputMethodInformation" = true;
              "ShowFirstInputMethodInformation" = true;
              "DefaultPageSize" = 5;
              "OverrideXkbOption" = false;
              "CustomXkbOption" = "";
              "EnabledAddons" = "";
              "DisabledAddons" = "";
              "PreloadInputMethod" = true;
              "AllowInputMethodForPassword" = false;
              "ShowPreeditForPassword" = false;
              "AutoSavePeriod" = 30;
            };
          };
        };
      };
    };
  };
}
