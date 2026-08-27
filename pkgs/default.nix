{ pkgs, lib }:

let
  pluginFiles = lib.filterAttrs (
    name: type: type == "regular" && name != "default.nix" && lib.hasSuffix ".nix" name
  ) (builtins.readDir ./.);

  self =
    let
      callPackage = lib.callPackageWith (pkgs // self);

      buildOmarchyPlugin = callPackage ../modules/omarchy-quickshell-nix/plugins.nix { };
    in
    {
      inherit buildOmarchyPlugin callPackage;
    }
    // lib.mapAttrs' (
      name: _type: lib.nameValuePair (lib.removeSuffix ".nix" name) (callPackage (./. + "/${name}") { })
    ) pluginFiles;
in
self
