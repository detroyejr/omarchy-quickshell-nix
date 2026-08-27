{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.omarchy-quickshell;

  settingType = lib.types.attrsOf lib.types.anything;

  pluginPackageType = lib.mkOptionType {
    name = "omarchy-plugin-package";
    description = "Omarchy plugin package";
    check = value: lib.isDerivation value && value ? passthru && value.passthru ? omarchyPlugin;
  };

  pluginType = lib.types.submodule (
    { config, ... }: {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          default = config.repo;
          defaultText = lib.literalExpression "repo";
          description = "Directory name to install the plugin under inside the Omarchy package.";
        };

        owner = lib.mkOption {
          type = lib.types.str;
          example = "acme";
          description = "GitHub owner for the plugin repository.";
        };

        repo = lib.mkOption {
          type = lib.types.str;
          example = "omarchy-weather";
          description = "GitHub repository name for the plugin.";
        };

        rev = lib.mkOption {
          type = lib.types.str;
          example = "main";
          description = "Git revision, tag, or branch to fetch.";
        };

        hash = lib.mkOption {
          type = lib.types.str;
          example = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          description = "Fixed-output hash for the fetched GitHub source.";
        };

      };
    }
  );

  finalPackage = cfg.package.override {
    extraPlugins = cfg.plugins;
    shellConfig = builtins.toJSON cfg.settings;
    enableMenu = cfg.menu.enable;
    enableBackground = cfg.background.enable;
  };

in
{
  options.programs.omarchy-quickshell = {
    enable = lib.mkEnableOption "the Omarchy Quickshell package and session environment";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./omarchy.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ./omarchy.nix { }";
      description = ''
        Base Omarchy shell package. It must support `override` with the
        `extraPlugins` and `shellConfig` arguments.
      '';
    };

    menu.enable = lib.mkEnableOption "enable the menu system for omarchy";
    background.enable = lib.mkEnableOption "enable omarchy's themeing system";

    plugins = lib.mkOption {
      type = lib.types.listOf (lib.types.either pluginPackageType pluginType);
      default = [ ];
      example = lib.literalExpression ''
        with pkgs.omarchyPlugins; [
          myPlugin
          anotherPlugin
        ]
      '';
      description = ''
        Omarchy plugins bundled into `$OMARCHY_PATH/shell/plugins`.
        Entries can either be plugin packages from `pkgs.omarchyPlugins` or
        inline GitHub fetch definitions.
      '';
    };

    settings = lib.mkOption {
      default = { };
      description = "Typed defaults for Omarchy's `shell.json`.";
      type = lib.types.submodule {
        options = {
          version = lib.mkOption {
            type = lib.types.int;
            default = 1;
            description = "Top-level shell.json schema version.";
          };

          idle = {
            screensaver = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              default = 150;
              description = "Seconds before the screensaver starts.";
            };

            lock = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              default = 300;
              description = "Seconds before the session locks.";
            };
          };

          bar = {
            id = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              example = "omarchy.bar";
              description = "Active bar plugin id for the default shell.json.";
            };

            position = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = "top";
              example = "bottom";
              description = "Bar position for the default shell.json.";
            };

            transparent = lib.mkOption {
              type = lib.types.nullOr lib.types.bool;
              default = false;
              description = "Whether the default bar starts transparent.";
            };

            centerAnchor = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = "omarchy.clock";
              example = "omarchy.clock";
              description = "Widget id the default bar centers around.";
            };

            layout = {
              left = lib.mkOption {
                type = lib.types.nullOr (lib.types.listOf settingType);
                default = null;
                description = "Default left bar section entries.";
              };

              center = lib.mkOption {
                type = lib.types.nullOr (lib.types.listOf settingType);
                default = null;
                description = "Default center bar section entries.";
              };

              right = lib.mkOption {
                type = lib.types.nullOr (lib.types.listOf settingType);
                default = null;
                description = "Default right bar section entries.";
              };
            };
          };

          plugins = lib.mkOption {
            type = lib.types.nullOr (lib.types.listOf settingType);
            default = [ ];
            description = "Default top-level `plugins[]` entries in shell.json.";
          };

          disabledPlugins = lib.mkOption {
            type = lib.types.nullOr (lib.types.listOf lib.types.str);
            default = null;
            description = "Built-in non-widget plugins to disable by default.";
          };
        };

        config = {
          bar.layout.left = [
            { id = "omarchy.menu"; }
            { id = "omarchy.workspaces"; }
          ];

          bar.layout.center = [
            { id = "omarchy.indicators"; }
            {
              id = "omarchy.clock";
              format = "dddd HH:mm";
              formatAlt = "d MMMM 'W'ww yyyy";
              verticalFormat = "HH\n—\nmm";
            }
            { id = "omarchy.keyboard-layout"; }
            { id = "omarchy.weather"; }
            { id = "omarchy.system-update"; }
          ];

          bar.layout.right = [
            { id = "omarchy.tray"; }
            { id = "omarchy.agents"; }
            { id = "omarchy.bluetooth"; }
            { id = "omarchy.network"; }
            { id = "omarchy.audio"; }
            { id = "omarchy.monitor"; }
            { id = "omarchy.power"; }
          ];
        };
      };
      example = {
        bar = {
          position = "bottom";
          transparent = true;
          layout.left = [
            { id = "omarchy.menu"; }
            { id = "omarchy.workspaces"; }
          ];
        };
        plugins = [
          {
            id = "community.weather-extra";
            units = "metric";
          }
        ];
        disabledPlugins = [ "omarchy.notifications" ];
      };
    };

    finalPackage = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      description = "Resolved Omarchy shell package with declarative plugins and default shell.json overrides applied.";
    };

  };

  config = {
    nixpkgs.overlays = [
      (final: _prev: {
        omarchy-quickshell = final.callPackage ./omarchy.nix { };
        omarchyPlugins = import ../../pkgs {
          inherit (final) lib;
          pkgs = final;
        };
      })
    ];
    programs.omarchy-quickshell.finalPackage = finalPackage;

    programs.chromium.enable = true;

    environment.systemPackages = [
      cfg.finalPackage
      pkgs.quickshell
      pkgs.chromium
    ];

    fonts = {
      enableDefaultPackages = true;
      packages = lib.mkBefore [ pkgs.nerd-fonts.iosevka finalPackage ];

      fontDir.enable = true;
      fontconfig = {
        defaultFonts = {
          serif = lib.mkAfter [ "Iosevka" ];
          sansSerif = lib.mkAfter [ "Iosevka" ];
          monospace = lib.mkAfter [ "Iosevka" ];
        };
      };
    };

    system.activationScripts.omarchyPath.text = ''
      mkdir -p /etc/omarchy \
        && cp -r ${cfg.finalPackage}/share/omarchy/* /etc/omarchy \
        && chmod -R 777 /etc/omarchy
    '';

    security.pam.services.omarchy-lock-password.text = ''
      #%PAM-1.0
      auth       required                    pam_faillock.so preauth silent deny=10 unlock_time=120
      -auth      [success=2 default=ignore]  pam_systemd_home.so
      auth       [success=1 default=bad]     pam_unix.so try_first_pass nullok
      auth       [default=die]               pam_faillock.so authfail deny=10 unlock_time=120
      auth       optional                    pam_permit.so
      auth       required                    pam_env.so
      auth       required                    pam_faillock.so authsucc
      account    include                     system-local-login
    '';

    security.pam.services.omarchy-lock-fingerprint.text = lib.mkIf config.services.fprintd.enable ''
      #%PAM-1.0
      auth       required                    pam_fprintd.so
      account    include                     system-local-login
    '';
  };
}
