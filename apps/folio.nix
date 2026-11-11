{
  fetchFromGitHub,
  ffmpegthumbnailer,
  glib,
  hicolor-icon-theme,
  lib,
  libarchive,
  pkg-config,
  qt6,
  stdenv,
  xdg-desktop-portal,
  xdg-terminal-exec,
  xdg-utils,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "folio";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "folio";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xXhebAKRBBKDpmB1dLC5L4qfxUMOqZRVHwQ6NmsJJ7I=";
  };

  nativeBuildInputs = [
    pkg-config
    qt6.qmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    glib
    hicolor-icon-theme
    libarchive
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtmultimedia
    qt6.qtwayland
    xdg-desktop-portal
    xdg-utils
    zlib
  ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    mkdir -p "$NIX_BUILD_TOP/build"
    cd "$NIX_BUILD_TOP/build"
    qmake6 "$src/folio.pro"
    make -j"$NIX_BUILD_CORES"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 "$NIX_BUILD_TOP/build/folio" "$out/bin/folio"
    install -Dm644 "$src/LICENSE" "$out/share/licenses/folio/LICENSE"
    install -Dm644 "$src/pkgbuild/folio.svg" \
      "$out/share/icons/hicolor/scalable/apps/folio.svg"
    install -Dm644 "$src/pkgbuild/folio.desktop" \
      "$out/share/applications/folio.desktop"
    install -Dm644 "$src/README.md" "$out/share/doc/folio/README.md"

    runHook postInstall
  '';

  qtWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      ffmpegthumbnailer
      glib
      xdg-desktop-portal
      xdg-terminal-exec
      xdg-utils
    ])
    "--set-default"
    "OMARCHY_PATH"
    "/etc/omarchy"
  ];

  meta = {
    description = "Files: Omarchy's keyboard-first, theme-following file manager";
    homepage = "https://github.com/omacom/folio";
    license = lib.licenses.mit;
    mainProgram = "folio";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
