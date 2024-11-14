{
  pkgs,
  lib,
  apps,
  wm,
  ...
}:
let
  linuxNegativeBindings =
    pkgs.fetchFromGitHub {
      owner = "codebling";
      repo = "vs-code-default-keybindings";
      rev = "8b5cca139fd94c537c55433476b74f4aaace13c5";
      sha256 = "sha256-BxA1L3ZeAtcg4PDPUWbpK8PPg/JaQ8SOTtQafaRhMUY=";
    }
    + "/linux.negative.keybindings.json";

  macosBindings =
    pkgs.fetchFromGitHub {
      owner = "codebling";
      repo = "vs-code-default-keybindings";
      rev = "8b5cca139fd94c537c55433476b74f4aaace13c5";
      sha256 = "sha256-BxA1L3ZeAtcg4PDPUWbpK8PPg/JaQ8SOTtQafaRhMUY=";
    }
    + "/macos.keybindings.json";

  dVsCodeKeybindings = derivation {
    name = "keybindings.json";
    builder = "${pkgs.bash}/bin/bash";
    args = [
      "-c"
      "${pkgs.coreutils}/bin/cat ${linuxNegativeBindings} ${macosBindings} | ${pkgs.gnugrep}/bin/grep -v '^\\s*//' | ${pkgs.jq}/bin/jq -s add > $out"
    ];
    system = pkgs.system;
  };

  #   fsKwinScript = lib.fileset;
  #   dKwinScript = pkgs.stdenv.mkDerivation {
  #     name = "fileset";
  #     src = fsKwinScript.toSource {
  #       root = ./../script;
  #       fileset = ./../script;
  #     };
  #     postInstall = ''
  #       mkdir $out
  #       cp -R * $out
  #     '';
  #   };

  #   fsKeymapperConfig = lib.fileset;
  #   dKeymapperConfig = pkgs.stdenv.mkDerivation {
  #     name = "fileset";
  #     src = fsKeymapperConfig.toSource {
  #       root = ./..;
  #       fileset = ./../keymapper.conf;
  #     };
  #     postInstall = ''
  #       mkdir $out
  #       cp keymapper.conf $out
  #     '';
  #   };

in
{
  home.stateVersion = "23.11";

  # Kernel level key remapping happens via keymapper
  home.file.".config/keymapper.conf".source = ../keymapper.conf;

  # KWin Script to make Keymapper application aware
  # (i.e. it knows about different window classes)
  home.file.".local/share/kwin/scripts/keymapper" = lib.mkIf (wm == "KWin") {
    source = ../script;
    recursive = true;
  };

  # Application mapping, e.g. VS Code
  home.file.".config/Code/User/keybindings.json".source = lib.mkIf (
    (__length (builtins.filter (x: x == "vs-code") apps)) != 0
  ) dVsCodeKeybindings;

  systemd.user.services.keymapper = {
    Unit.Description = "Keymapper client";
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      Type = "simple";
      Restart = "on-failure";
      StandardOutput = "journal";
      StandardError = "journal";
      ExecStart = "${pkgs.keymapper}/bin/keymapper --update --no-notify --verbose";
    };
  };
}
