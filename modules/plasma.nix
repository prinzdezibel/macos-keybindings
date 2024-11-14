{ pkgs, ... }:
{
  home.stateVersion = "23.11";

  programs = {

    plasma = {
      enable = true;

      #
      # Some mid-level settings: 
      #
      # ~/.config/kglobalshortcutsrc
      #
      shortcuts = {

        # ksmserver = {
        #   "Lock Session" = [
        #     "Screensaver"
        #     "Ctrl+Shift+Eject" # Lock Session | now: Control + Shift + Eject | default: Meta+L
        #   ];
        # };

        # yields [services][systemsettings.desktop]
        "services/systemsettings.desktop" = {
          _launch = "Meta+<"; # Show System settings | now: Command + Shift + ,
        };

        "services/org.kde.kscreen.desktop" = {
          ShowOSD = "Meta+D"; # Switch Display | now: Command + Shift + D | default:Meta+P
        };

        "services/org.kde.krunner.desktop" = {
          RunClipboard = "Meta+Space";
        };

        "org_kde_powerdevil" = {
          powerProfile = "none"; # default: Meta+B | now: Not in use because TLP service automatically controls power profiles.
        };

        "plasmashell" = {
          "MoveZoomDown" = "none"; # Move Down | default: Meta+Ctrl+Down
          "MoveZoomLeft" = "none"; # Move Left | default: Meta+Ctrl+Left
          "MoveZoomRight" = "none"; # Move Right | default: Meta+Ctrl+Right
          "MoveZoomUp" = "none"; # Move Up | default: Meta+Ctrl+Up
          "manage activities" = "none"; # Show Activity Switcher | default: Meta+Q
          "stop current activity" = "none"; # default: Meta + S
          "show-on-mouse-pos" = "none"; # Show Clipboard Items at Mouse Position | default: Meta+V
          "activate application launcher" = "none"; # Alt+F1,Meta
          "show dashboard" = "F11"; # Show Desktop | default: Ctrl+F12 | new: F11
        };
      };

      #
      # Some low-level settings:
      #
      #
      configFile = {

        #
        # ~/.config/kdeglobals
        #
        kdeglobals = {
          Shortcuts.Preferences = "Meta+,";
          Shortcuts.ShowHideHiddenFiles = "Meta+>";
          "KFileDialog Settings" = {
            "Show hidden files" = true;
          };
        };

        # ~/.config/kxkbrc
        kxkbrc = {
          Layout.LayoutList = "us";
          Layout.Model = "pc105";
          Layout.Use = "true";
          Layout.VariantList = "altgr-intl";
        };
      };
    };
  };
}
