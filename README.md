## Omarchy QuickShell for NixOS

An experimental nix module for Omarchy's QuickShell setup.

Repo layout:

- `modules/omarchy-quickshell-nix/` contains the base package and NixOS module
- `pkgs/` contains packaged plugins exposed as `pkgs.omarchyPlugins`

Quick NixOS example:

```nix
{ lib, pkgs, ... }:
{
  imports = [ /path/to/omarchy-quickshell-nix ];

  programs.omarchy-quickshell = {
    enable = true;
    plugins = with pkgs.omarchyPlugins; [ omarchy-pihole ];
    settings.bar.layout.right = lib.mkBefore [ { id = "io.github.detroyejr.omarchy-pihole"; } ];
  };
}
```

Flake NixOS example:

```nix
{ inputs, lib, pkgs, ... }:
{
  imports = [ inputs.omarchy-quickshell.nixosModules.default ];

  programs.omarchy-quickshell = {
    enable = true;
    plugins = with pkgs.omarchyPlugins; [ omarchy-pihole ];
    settings.bar.layout.right = lib.mkBefore [ { id = "io.github.detroyejr.omarchy-pihole"; } ];
  };
}
```
