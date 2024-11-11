{
  description = "Macos keymapping for Linux";

  inputs = {

    # Nix Package Manager
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      #inputs.nixpkgs.follows = "nixpkgs";
      #inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    { self, ... }@inputs:
    let
      plasma-manager = inputs.home-manager.nixosModules.home-manager {
        home-manager.backupFileExtension = "hm-backup";
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
        home-manager.users.michael = import ./plasma.nix;
      };

      kwin-manager = inputs.home-manager.nixosModules.home-manager {
        home-manager.backupFileExtension = "hm-backup";
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
        home-manager.users.michael = import ./kwin.nix;
      };
    in
    {

      nixosModules = rec {

        macos-keybindings = ./modules;
        default = macos-keybindings;

        kwin-manager = inputs.nixpkgs.lib.mkIf (macos-keybindings.wm == "KWin") (
          #import kwin-manager { macos-keybindings = macos-keybindings; }
          kwin-manager
        );

        plasma-manager = inputs.nixpkgs.lib.mkIf (macos-keybindings.de == "Plasma") (
          plasma-manager
        );
      };
    };
}
