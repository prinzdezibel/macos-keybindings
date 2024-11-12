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
    {
      nixosModules = rec {
        #macos-keybindings = (import ./modules);
        home-manager = inputs.home-manager.nixosModules.home-manager;
        macos-keybindings = (import ./modules {inherit (inputs) home-manager plasma-manager;});
        
        #macos-keybindings = (import ./modules);
        #macos-keybindings = (import ./modules {inherit inputs;}) // {home-manager = inputs.home-manager; plasma-manager = inputs.plasma-manager;};
        # macos-keybindings = inputs.nixpkgs.lib.mkMerge [
        #   (import ./modules)

        #   {plasma-manager = inputs.plasma-manager;}
        # ];

        # macos-keybindings = rec {
        #   inherit (import ./modules);
        #   #home-manager = inputs.home-manager;
        #   #inherit (inputs) plasma-manager;
        # };

        

        default = macos-keybindings;
      };
    };
}
