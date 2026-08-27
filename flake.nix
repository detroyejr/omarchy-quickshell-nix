{
  description = "Flake packaging Omarchy Quickshell with declarative NixOS integration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSystem = lib.genAttrs systems;

    in
    {
      packages = forEachSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (final: _prev: {
                omarchy-quickshell = final.callPackage ./modules/omarchy-quickshell-nix/omarchy.nix { };
                omarchyPlugins = import ./pkgs {
                  inherit (final) lib;
                  pkgs = final;
                };
              })
            ];
          };
          omarchy-quickshell = pkgs.omarchy-quickshell;
        in
        {
          inherit omarchy-quickshell;
          default = omarchy-quickshell;
        }
      );

      formatter = forEachSystem (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.nixfmt
      );

      overlays.default = (
        final: _prev: {
          omarchy-quickshell = final.callPackage ./modules/omarchy-quickshell-nix/omarchy.nix { };
          omarchyPlugins = import ./pkgs {
            inherit (final) lib;
            pkgs = final;
          };
        }
      );

      omarchyPlugins = forEachSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (final: _prev: {
                omarchy-quickshell = final.callPackage ./modules/omarchy-quickshell-nix/omarchy.nix { };
                omarchyPlugins = import ./pkgs {
                  inherit (final) lib;
                  pkgs = final;
                };
              })
            ];
          };
        in
        pkgs.omarchyPlugins
      );

      nixosModules = {
        default = import ./modules/omarchy-quickshell-nix;
        omarchy-quickshell = self.nixosModules.default;
      };
    };
}
