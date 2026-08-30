{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  glib-networking,
  gtk3,
  importNpmLock,
  nodejs,
  pkg-config,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

let
  version = "4.29.8";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "aether";
    tag = "v${version}";
    hash = "sha256-gB6vRNoo309eAWhAhDFDiIzHjSBalKpOjafnx8wzZP0=";
  };

  frontend = stdenv.mkDerivation {
    pname = "aether-frontend";
    inherit version src;

    sourceRoot = "${src.name}/frontend";

    npmDeps = importNpmLock.buildNodeModules {
      npmRoot = "${src}/frontend";
      inherit nodejs;
      derivationArgs = {
        npmFlags = [ "--legacy-peer-deps" ];
      };
    };

    nativeBuildInputs = [
      nodejs
      importNpmLock.hooks.linkNodeModulesHook
    ];

    buildPhase = ''
      runHook preBuild

      npm run build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r dist $out

      runHook postInstall
    '';
  };
in
buildGoModule {
  pname = "aether";
  inherit version src;

  vendorHash = "sha256-0cNNFCI/hFYM/BmuHEDDunKf7byj8JCb0lRElsWWaT0=";

  # Wails uses the production tag to compile the real desktop runtime.
  tags = [ "production" "webkit2_41" ];
  ldflags = [ "-X aether/cli.Version=${version}" ];
  subPackages = [ "." ];

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    glib-networking
    gtk3
    webkitgtk_4_1
  ];

  overrideModAttrs = {
    preBuild = ''
      mkdir -p frontend/dist
    '';
  };

  preBuild = ''
    rm -rf frontend/dist
    cp -r ${frontend} frontend/dist
  '';

  postInstall = ''
    install -Dm644 assets/aether-icon-512.png "$out/share/icons/hicolor/512x512/apps/aether.png"
    install -Dm644 li.oever.aether.desktop "$out/share/applications/li.oever.aether.desktop"
    install -Dm644 li.oever.aether.url-handler.desktop "$out/share/applications/li.oever.aether.url-handler.desktop"
  '';

  meta = {
    description = "Desktop theming application for Omarchy and other Linux desktops";
    homepage = "https://github.com/omacom/aether";
    license = lib.licenses.mit;
    mainProgram = "aether";
    platforms = lib.platforms.linux;
  };
}
