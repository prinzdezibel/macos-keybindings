{ mac-keymock }:
{ pkgs, config, ... }:
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

        ksmserver = {
          "Lock Session" = [
            "Screensaver"
            "Ctrl+Shift+Eject" # Lock Session | now: Control + Shift + Eject | default: Meta+L
          ];
        };

        kwin = {
          "Show Desktop" = "none";
          "Overview" = "none"; # Toggle Overview | default: Meta+W
          "Grid View" = "none"; # Toggle Grid View | default: Meta+G
          "Expose" = "Ctrl+Up"; # Toogle Present Windows (Current Desktop) | default: Ctrl + F9
          "Walk Through Windows" = "Meta+Tab";
          "Walk Through Windows (Reverse)" = "Meta+Shift+Tab";
          "Window Tile Bottom" = [
            "none"
            "none"
          ];
          "Window Quick Tile Bottom Left" = [
            "none"
            "none"
          ];
          "Window Quick Tile Bottom Right" = [
            "none"
            "none"
          ];
          "Window Quick Tile Left" = [
            "none"
            "none"
          ];
          "Window Quick Tile Right" = [
            "none"
            "none"
          ];
          "Window Quick Tile Top" = [
            "none"
            "none"
          ];
          "Window Quick Tile Top Left" = [
            "none"
            "none"
          ];
          "Window Quick Tile Top Right" = [
            "none"
            "none"
          ];
          "Window to Next Screen" = [
            "none"
            "none"
          ];
          "Window to Previous Screen" = [
            "none"
            "none"
          ];
        };

        # # yields [services][systemsettings.desktop]
        # "services/systemsettings.desktop" = {
        #   _launch = "Meta+<"; # Show System settings | now: Command + Shift + ,
        # };

        # "services/org.kde.kscreen.desktop" = {
        #   ShowOSD = "Meta+D"; # Switch Display | now: Command + Shift + D | default:Meta+P
        # };

        # "services/org.kde.krunner.desktop" = {
        #   RunClipboard = "Meta+Space";
        # };
      };

      #
      # Some low-level settings:
      #
      #
      configFile = {

        kwinrc.Plugins.keymapperEnabled = true;

      };
    };
  };
}
