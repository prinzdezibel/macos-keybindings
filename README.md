# macos-keybindings

A MacOS keymapper for NixOS.

## Requirements

- NixOS Linux
- Wayland or Xorg
- KWin window manager
- KDE Plasma Desktop
- English keyboard layout


## Features

- Generic MacOS shortcuts for all applications through [keymapper](https://github.com/houmain/keymapper)
- KWin & Plasma shortcuts that emulate their MacOS counterparts
- Support for application specific keymappings 
- VS Code Keymapping plugin
  - Matches exactly the official [MacOS shortcuts](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-macos.pdf)


## Notice
Keyboard layout will be changed to English (intl., with AltGr dead keys) for keymapper to work properly. Various shortcuts in System Settings will be defined/overwritten.


## Installation for flake based setup (recommended)
```
{
  description = "NixOS configuration";

  inputs = {
    macos-keybindings = {
       url = "github:prinzdezibel/macos-keybindings";
    };
  };
  
  outputs = {self, macos-keybindings, ...} : {
    nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
      modules = [
          macos-keybindings.modules
          {
            accounts = [{
                user = "michael";
                apps = [ "vs-code" ];
                wm = "KWin";
                de = "Plasma";
            }];
          }
      ];
    };
  };
}
```


## Installation for module based setup

1. Add channel 
```
$ sudo nix-channel --add https://github.com/prinzdezibel/macos-keybindings/archive/main.tar.gz macos-keybindings
$ sudo nix-channel --update
```

2. Add macos-keybindings module to configuration.nix

```
{ config, pkgs, ...}:
{
  imports = [
    ./hardware-configuration.nix

    <macos-keybindings/modules>
  ]

  macos-keybindings = [{
    user = "michael";
    apps = [ "vs-code" ];
    wm = "KWin";
    de = "Plasma";
  }];

}

```

