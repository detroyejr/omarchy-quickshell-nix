## Omarchy QuickShell for NixOS

An experimental nix module for Omarchy's QuickShell setup.

Repo layout:

- `modules/omarchy-quickshell-nix/` contains the base package and NixOS module
- `pkgs/` contains packaged plugins exposed as `pkgs.omarchyPlugins`

Quick NixOS example:

```nix
{ lib, pkgs, ... }:
{
  imports = [ ({builtins.fetchGit { url = "https://github.com/detroyejr/omarchy-quickshell-nix"; }) ];

  programs.omarchy-quickshell = {
    enable = true;
    plugins = [ pkgs.omarchyPlugins."omarchy-pihole" ];
    settings.bar.layout.right = lib.mkBefore [ { id = pkgs.omarchyPlugins."omarchy-pihole".id; } ];
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
    plugins = [ pkgs.omarchyPlugins."omarchy-pihole" ];
    settings.bar.layout.right = lib.mkBefore [ { id = pkgs.omarchyPlugins."omarchy-pihole".id; } ];
  };
}
```

To hide an app from the launcher, configure its desktop-entry ID explicitly:

```nix
programs.omarchy-quickshell.launcher.hiddenEntries = [ "Discord" ];
```

### Voxtype dictation

Enable Voxtype to install its CLI and start its daemon with the graphical
session:

```nix
programs.omarchy-quickshell = {
  enable = true;
  voxtype.enable = true;
};
```

After switching to the new system, download the default Whisper model once:

```bash
voxtype setup --download
```

The daemon starts automatically at graphical-session login. To start it now,
run `systemctl --user restart voxtype.service`; check it with
`systemctl --user status voxtype.service`. Voxtype uses its built-in defaults
unless you create `~/.config/voxtype/config.toml`.
