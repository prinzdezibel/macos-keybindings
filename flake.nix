{
  description = "Macos keymapping for Linux";

  inputs = {

    # Nix Package Manager
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager?ref=master";
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
      home-manager = inputs.home-manager.nixosModules.home-manager;
      plasma-manager = inputs.plasma-manager.homeManagerModules.plasma-manager; 
    in
    {
      nixosModules = rec {
        macos-keybindings = (import ./modules {inherit home-manager plasma-manager;});
        default = macos-keybindings;
      };
    };
}
