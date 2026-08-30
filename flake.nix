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
                aether = final.callPackage ./modules/omarchy-quickshell-nix/aether.nix { };
                omarchy-quickshell = final.callPackage ./modules/omarchy-quickshell-nix/omarchy.nix { };
                omarchyPlugins = import ./pkgs {
                  inherit (final) lib;
                  pkgs = final;
                };
                ttfx = final.callPackage ./modules/omarchy-quickshell-nix/ttfx.nix { };
              })
            ];
          };
          omarchy-quickshell = pkgs.omarchy-quickshell;
        in
        {
          inherit (pkgs) aether;
          inherit (pkgs) ttfx;
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
          aether = final.callPackage ./modules/omarchy-quickshell-nix/aether.nix { };
          omarchy-quickshell = final.callPackage ./modules/omarchy-quickshell-nix/omarchy.nix { };
          omarchyPlugins = import ./pkgs {
            inherit (final) lib;
            pkgs = final;
          };
          ttfx = final.callPackage ./modules/omarchy-quickshell-nix/ttfx.nix { };
        }
      );

      omarchyPlugins = forEachSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (final: _prev: {
                aether = final.callPackage ./modules/omarchy-quickshell-nix/aether.nix { };
                omarchy-quickshell = final.callPackage ./modules/omarchy-quickshell-nix/omarchy.nix { };
                omarchyPlugins = import ./pkgs {
                  inherit (final) lib;
                  pkgs = final;
                };
                ttfx = final.callPackage ./modules/omarchy-quickshell-nix/ttfx.nix { };
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
