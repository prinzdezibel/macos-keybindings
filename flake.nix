{
  description = "Macos keymapping for Linux";

  inputs = {

    # Nix Package Manager
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.05";
      #url = "github:nix-community/home-manager?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      self,
      home-manager,
      plasma-manager,
      ...
    }:
    let
      home-manager-module = home-manager.nixosModules.home-manager;
      plasma-manager-module = plasma-manager.homeManagerModules.plasma-manager;
    in
    {
      nixosModules = (
        {
          config,
          lib,
          pkgs,
          ...
        }:
        (import ./modules (
          {
            inherit
              lib
              config
              pkgs
              ;
          }
          // {
            _home-manager = home-manager-module;
            _plasma-manager = plasma-manager-module;
          }
        ))
      );
    };
}
