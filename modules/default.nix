{ home-manager, plasma-manager, ... }:
{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
{
  
  imports = [
    # Keymapper config
    home-manager.nixosModules.home-manager
    {
      home-manager.backupFileExtension = "hm-backup";
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.users = builtins.listToAttrs (
        map (
          {
            user,
            app-keybindings,
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
                  app-keybindings
                  wm
                  ;
              }
            );
          }
        ) config.accounts
      );
    }

    # Kwin config
    home-manager.nixosModules.home-manager
    {
      home-manager.backupFileExtension = "hm-backup";
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];

      home-manager.users = builtins.listToAttrs (
        map (
          {
            user,
            app-keybindings,
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
                  app-keybindings
                  de
                  wm
                  ;
              }
            );
          }
        ) (builtins.filter (x: x.wm == "KWin") config.accounts)
      );
    }

    # Plasma config
    home-manager.nixosModules.home-manager
    {
      home-manager.backupFileExtension = "hm-backup";
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];

      home-manager.users = builtins.listToAttrs (
        map (
          {
            user,
            app-keybindings,
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
                  app-keybindings
                  de
                  wm
                  ;
              }
            );
          }
        ) (builtins.filter (x: x.wm == "Plasma") config.accounts)
      );
     }
  ];

  options = {


  #  home-manager = lib.mkOptions {

  #  };
  #  plasma-manager = lib.mkOptions {

  #  };

    accounts = lib.mkOption {
      default = [ ];
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            user = lib.mkOption {
              type = lib.types.str;
            };

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
        }
      );
    };

  };

  config = {
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
  };
}
