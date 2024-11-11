{
  config,
  lib,
  pkgs,
  ...
}:
let

  fsKwinScript = lib.fileset;
  dKwinScript = pkgs.stdenv.mkDerivation {
    name = "fileset";
    src = fsKwinScript.toSource {
      root = ./../script;
      fileset = ./../script;
    };
    postInstall = ''
      mkdir $out
      cp -R * $out
    '';
  };

  fsKeymapperConfig = lib.fileset;
  dKeymapperConfig = pkgs.stdenv.mkDerivation {
    name = "fileset";
    src = fsKeymapperConfig.toSource {
      root = ./..;
      fileset = ./../keymapper.conf;
    };
    postInstall = ''
      mkdir $out
      cp keymapper.conf $out
    '';
  };

  linuxNegativeBindings = pkgs.fetchFromGitHub {
    owner = "codebling";
    repo = "vs-code-default-keybindings";
    rev = "8b5cca139fd94c537c55433476b74f4aaace13c5";
    sha256 = "sha256-BxA1L3ZeAtcg4PDPUWbpK8PPg/JaQ8SOTtQafaRhMUY=";
  } + "/linux.negative.keybindings.json";

  macosBindings = pkgs.fetchFromGitHub {
    owner = "codebling";
    repo = "vs-code-default-keybindings";
    rev = "8b5cca139fd94c537c55433476b74f4aaace13c5";
    sha256 = "sha256-BxA1L3ZeAtcg4PDPUWbpK8PPg/JaQ8SOTtQafaRhMUY=";
  } + "/macos.keybindings.json";

  dVsCodeKeybindings = derivation {
    name = "keybindings.json";
    builder = "${pkgs.bash}/bin/bash";
    args = [
      "-c"
      "${pkgs.coreutils}/bin/cat ${linuxNegativeBindings} ${macosBindings} | ${pkgs.gnugrep}/bin/grep -v '^\\s*//' | ${pkgs.jq}/bin/jq -s add > $out"
    ];
    system = pkgs.system;
  };
in
{
  options = {

    app-keybindings = lib.mkOption {
      default = [ ];
      type = lib.types.listOf (lib.types.enum [ "vs-code" ]);
    };

    wm = lib.mkOption {
      type = lib.types.enum [ "KWin" ];
      default = "KWin";
    };

    de = lib.mkOption {
      type = lib.types.enum [ "Plasma" ];
      default = "Plasma";
    };
  };

  config = lib.mkMerge [

    (lib.mkIf ((__length (builtins.filter (x: x == "vs-code") config.app-keybindings)) != 0) {
      system.userActivationScripts.linktokeymapperScript.text = ''
        ln -s ${dVsCodeKeybindings} "$HOME/.config/Code/User/keybindings.json"
      '';
    })

    (lib.mkIf (config.wm == "KWin") {
      system.userActivationScripts.linktokeymapperScript.text = ''
        if [[ ! -h "$HOME/.local/share/kwin/scripts/keymapper" ]]; then
          ln -s ${dKwinScript} "$HOME/.local/share/kwin/scripts/keymapper"
        fi
      '';
    })

    {
      system.userActivationScripts.linktoKeymapperConfig.text = ''
        if [[ ! -h "$HOME/.config/keymapper.conf" ]]; then
          ln -s ${dKeymapperConfig.out}/keymapper.conf "$HOME/.config/keymapper.conf"
        fi
      '';
    }

    {
      environment.systemPackages = with pkgs; [ pkgs.keymapper ];

      systemd.services.keymapperd = {
        enable = true;
        description = "Keymapper Daemon";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.keymapper}/bin/keymapperd --verbose";
          Restart = "always";
          RestartSec = "30";
        };
      };

      systemd.user.services.keymapper = {
        enable = true;
        wantedBy = [ "graphical-session.target" ];
        description = "Keymapper client";
        serviceConfig = {
          #Type = "dbus";
          #BusName = "com.github.houmain.Keymapper";
          Type = "simple";
          Restart = "on-failure";
          StandardOutput = "journal";
          StandardError = "journal";
          ExecStart = "${pkgs.keymapper}/bin/keymapper --update --no-notify --verbose";
        };
      };
    }
  ];
}
