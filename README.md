# macos-keybindings

A MacOS keymapper for nix-packaged Linux systems.

## Prerequisites

- Nix package management 
- Linux (Windows platform may also work, not tested)
- Wayland or Xorg (not strictly needed, but recommended)
- KDE Plasma + KWin windows manager (not strictly needed, but recommended)

Features:
- Generic MacOS shortcuts for all applications through [keymapper](https://github.com/houmain/keymapper)
- KWin & Plasma shortcuts are defined to match Apple's counterparts
- Application specific keymapping for VS Code to match exactly [MacOS shortcuts](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-macos.pdf). More information: [codebling](https://github.com/codebling/vs-code-default-keybindings) 

 

## Installation for flake based setup (recommended)
```
{
  description = "NixOS configuration";

  inputs = {
  };
  outputs = {self, ....}@inputs:{
    nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
      modules = [
          inputs.macos-keybindings.nixosModules.macos-keybindings
          {
            accounts = [
              {
                user = "michael";
                app-keybindings = [ "vs-code" ];
                wm = "KWin";
                de = "Plasma";
              }
            ];
          }
      ];
    };
  };
}

```

