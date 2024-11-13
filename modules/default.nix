{
  config,
  lib,
  pkgs,
  home-manager ? (
    let
      nixpkgs = import <nixpkgs> { };
      home-manager-source = nixpkgs.fetchFromGitHub {
        owner = "nix-community";
        repo = "home-manager";
        rev = "master";
        sha256 = "sha256-NjavpgE9/bMe/ABvZpyHIUeYF1mqR5lhaep3wB79ucs=";
      };
    in
    (import "${home-manager-source}/nixos")
  ),
  plasma-manager ? (
    let
      nixpkgs = import <nixpkgs> { };
      plasma-manager-source = nixpkgs.fetchFromGitHub {
        owner = "nix-community";
        repo = "plasma-manager";
        rev = "master";
        sha256 = "sha256-pGF8L5g9QpkQtJP9JmNIRNZfcyhJHf7uT+d8tqI1h6Y=";
      };
    in
    (import "${plasma-manager-source}/modules")
  ),
  ...
}:
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
