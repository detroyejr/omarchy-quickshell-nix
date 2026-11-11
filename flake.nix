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
      omarchyAppsOverlay = final: _prev: import ./apps { inherit (final) callPackage; };

    in
    {
      packages = forEachSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              omarchyAppsOverlay
              (final: _prev: {
                aether = final.callPackage ./modules/omarchy-quickshell-nix/aether.nix { };
                omarchy-screensaver =
                  final.callPackage ./modules/omarchy-quickshell-nix/omarchy-screensaver.nix
                    { };
                omasnap = final.callPackage ./modules/omarchy-quickshell-nix/omasnap.nix { };
                omarchy-hyprland-titlebars =
                  final.callPackage ./modules/omarchy-quickshell-nix/omarchy-hyprland-titlebars.nix
                    { };
                omarchy-quickshell = final.callPackage ./modules/omarchy-quickshell-nix/omarchy.nix {
                  inherit (final) omasnap;
                  screensaverPackage = final.omarchy-screensaver;
                  titlebarsPackage = final.omarchy-hyprland-titlebars;
                };
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
          inherit (pkgs)
            aether
            omarchy-screensaver
            omasnap
            omarchy-hyprland-titlebars
            hype
            signed
            disktree
            monologue
            folio
            ;
          inherit (pkgs) gliff;
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
        final: _prev:
        let
          apps = import ./apps { inherit (final) callPackage; };
        in
        apps
        // {
          aether = final.callPackage ./modules/omarchy-quickshell-nix/aether.nix { };
          omarchy-screensaver =
            final.callPackage ./modules/omarchy-quickshell-nix/omarchy-screensaver.nix
              { };
          omasnap = final.callPackage ./modules/omarchy-quickshell-nix/omasnap.nix { };
          omarchy-hyprland-titlebars =
            final.callPackage ./modules/omarchy-quickshell-nix/omarchy-hyprland-titlebars.nix
              { };
          omarchy-quickshell = final.callPackage ./modules/omarchy-quickshell-nix/omarchy.nix {
            inherit (final) omasnap;
            screensaverPackage = final.omarchy-screensaver;
            titlebarsPackage = final.omarchy-hyprland-titlebars;
          };
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
              omarchyAppsOverlay
              (final: _prev: {
                aether = final.callPackage ./modules/omarchy-quickshell-nix/aether.nix { };
                omarchy-screensaver =
                  final.callPackage ./modules/omarchy-quickshell-nix/omarchy-screensaver.nix
                    { };
                omasnap = final.callPackage ./modules/omarchy-quickshell-nix/omasnap.nix { };
                omarchy-hyprland-titlebars =
                  final.callPackage ./modules/omarchy-quickshell-nix/omarchy-hyprland-titlebars.nix
                    { };
                omarchy-quickshell = final.callPackage ./modules/omarchy-quickshell-nix/omarchy.nix {
                  inherit (final) omasnap;
                  screensaverPackage = final.omarchy-screensaver;
                  titlebarsPackage = final.omarchy-hyprland-titlebars;
                };
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
