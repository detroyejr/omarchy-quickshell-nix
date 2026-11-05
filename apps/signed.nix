{
  lib,
  fetchFromGitHub,
  stdenv,
  pkg-config,
  qt6,
  qt6Packages,
  qpdf,
  nss,
  noto-fonts,
  xdg-desktop-portal,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "signed";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "signed";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fH5jXdO0uNsRblramzU0lcP3Dvv7pMZjf41FdE3lKjY=";
  };

  nativeBuildInputs = [
    pkg-config
    qt6.qmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtwayland
    qt6Packages.poppler
    qpdf
    nss
    noto-fonts
    xdg-desktop-portal
  ];

  configurePhase = ''
    runHook preConfigure

    mkdir -p "$NIX_BUILD_TOP/build"
    cd "$NIX_BUILD_TOP/build"
    qmake6 "$src/signed.pro"

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    cd "$NIX_BUILD_TOP/build"
    make -j$NIX_BUILD_CORES

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 "$NIX_BUILD_TOP/build/signed" $out/bin/signed
    install -Dm644 "$src/LICENSE" $out/share/licenses/signed/LICENSE
    install -Dm644 "$src/pkgbuild/signed.desktop" $out/share/applications/signed.desktop
    install -Dm644 "$src/pkgbuild/signed.svg" $out/share/icons/hicolor/scalable/apps/signed.svg

    runHook postInstall
  '';

  meta = {
    description = "Sign PDFs and fill them in with text and dates";
    homepage = "https://github.com/omacom/signed";
    license = lib.licenses.mit;
    mainProgram = "signed";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
