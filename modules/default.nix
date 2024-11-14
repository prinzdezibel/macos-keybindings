{
  config,
  lib,
  pkgs,
  system ? builtins.currentSystem,
  _home-manager ? null,
  _plasma-manager ? null,
  ...
}:
let

  nixpkgsVersion = builtins.substring 0 5 lib.version ;
  
  msg = builtins.trace "Your current nixpkgs version is: ${nixpkgsVersion}"; 
  _ = msg;
  assertCorrectVersion = if nixpkgsVersion < "24.11" then abort ''
    For keymapper to work, you need ot install nixpkg version >= 24.11.
    
    Your current nixpkgs version is: ${nixpkgsVersion}   
    
    Consider upgrading your system. E.g. for nixos 
    $ sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
    $ sudo nixos-rebuild switch --upgrade

  '' else {...}@inputs: inputs;

  # use nixpkgs version >= 24.05 for keymapper to work
  # pinnedNixpkgs = builtins.fromJSON (builtins.readFile ../pinned-nixpkgs.json);
  # nixpkgs' = builtins.fetchTarball {
  #   url = "https://github.com/NixOS/nixpkgs/archive/${pinnedNixpkgs.rev}.tar.gz";
  #   sha256 = "${pinnedNixpkgs.sha256}";
  # };
  # pkgs = import nixpkgs' {
  #   inherit system;
  #   #system = builtins.currentSystem;
  #   config = { };
  #   overlays = [ ];
  # };

  home-manager =
    # Hack to prevent indefinite recursions
    if builtins.hasAttr "currentSystem" builtins then
      with rec {
        _nixpkgs = import <nixpkgs> { };
        version = builtins.substring 0 5 _nixpkgs.lib.version;
        maxVersion = if version > "24.05" then "24.05" else version;
        home-manager-source = builtins.fetchTarball {
          url = "https://github.com/nix-community/home-manager/archive/release-${maxVersion}.tar.gz";
        };

        #home-manager-source = _nixpkgs.fetchFromGitHub {
        #  owner = "nix-community";
        #  repo = "home-manager";
        #  rev = "60bb110917844d354f3c18e05450606a435d2d10";
        #  sha256 = "sha256-NjavpgE9/bMe/ABvZpyHIUeYF1mqR5lhaep3wB79ucs=";
        #};
      };
      (import "${home-manager-source}/nixos")
    else
      _home-manager;

  plasma-manager =
    # Hack to prevent indefinite recursions
    if builtins.hasAttr "currentSystem" builtins then
      with rec {
        nixpkgs = import <nixpkgs> { };
        plasma-manager-source = builtins.fetchTarball {
          url = "https://github.com/nix-community/plasma-manager/archive/trunk.tar.gz";
        };
        #plasma-manager-source = nixpkgs.fetchFromGitHub {
        #  owner = "nix-community";
        #  repo = "plasma-manager";
        #  rev = "f33173b9d22e554a6f869626bc01808d35995257";
        #  sha256 = "sha256-pGF8L5g9QpkQtJP9JmNIRNZfcyhJHf7uT+d8tqI1h6Y=";
        #};
      };
      (import "${plasma-manager-source}/modules")
    else
      _plasma-manager;
in
msg
assertCorrectVersion
{
  imports = [

    home-manager
    {
      home-manager.backupFileExtension = "hm-backup";
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.sharedModules = [ plasma-manager ];

      home-manager.users = lib.mkMerge [

        # Keymapper config
        (builtins.listToAttrs (
          map (
            {
              user,
              apps,
              wm,
              ...
            }:
            {
              name = user;
              value = (
                import ./keymapper.nix {
                  inherit
                    pkgs
                    lib
                    apps
                    wm
                    ;
                }
              );
            }
          ) config.macos-keybindings
        ))

        # Kwin config
        (builtins.listToAttrs (
          map (
            {
              user,
              apps,
              wm,
              de,
            }:
            {
              name = user;
              value = (
                import ./kwin.nix {
                  inherit
                    pkgs
                    lib
                    apps
                    de
                    wm
                    ;
                }
              );
            }
          ) (builtins.filter (x: x.wm == "KWin") config.macos-keybindings)
        ))

        (
          # Plasma config
          builtins.listToAttrs (
            map (
              {
                user,
                apps,
                wm,
                de,
              }:
              {
                name = user;
                value = (
                  import ./plasma.nix {
                    inherit
                      pkgs
                      lib
                      apps
                      de
                      wm
                      ;
                  }
                );
              }
            ) (builtins.filter (x: x.wm == "Plasma") config.macos-keybindings)
          )

        )

      ];
    }

  ];

  options = {

    macos-keybindings = lib.mkOption {
      default = [ ];
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            user = lib.mkOption {
              type = lib.types.str;
            };

            apps = lib.mkOption {
              default = [ ];
              type = lib.types.listOf (lib.types.enum [ "vs-code" ]);
            };

            wm = lib.mkOption {
              default = null;
              type = lib.types.nullOr (lib.types.enum [ "KWin" ]);
            };

            de = lib.mkOption {
              default = null;
              type = lib.types.nullOr (lib.types.enum [ "Plasma" ]);
            };
          };
        }
      );
    };

  };

  config = {
    environment.systemPackages = [ pkgs.keymapper ];

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
  };
}
