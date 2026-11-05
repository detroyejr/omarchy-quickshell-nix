{
  fetchFromGitHub,
  ffmpeg,
  gnumake,
  lib,
  libpulseaudio,
  pkg-config,
  qt6,
  stdenv,
  xdg-desktop-portal,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "monologue";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "monologue";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sQm/n0kHl13JQ3iOcOM5rZcP9xqrPpw6EKTVBLWha/I=";
  };

  nativeBuildInputs = [
    gnumake
    pkg-config
    qt6.qmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    ffmpeg
    libpulseaudio
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtmultimedia
    xdg-desktop-portal
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p build
    (
      cd build
      qmake6 ../monologue.pro
      make -j"$NIX_BUILD_CORES"
    )

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 build/monologue "$out/bin/monologue"
    install -Dm644 LICENSE "$out/share/licenses/monologue/LICENSE"
    install -Dm644 pkgbuild/monologue.desktop \
      "$out/share/applications/monologue.desktop"
    install -Dm644 pkgbuild/monologue.svg \
      "$out/share/icons/hicolor/scalable/apps/monologue.svg"

    runHook postInstall
  '';

  qtWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      ffmpeg
      xdg-desktop-portal
    ])
  ];

  meta = {
    description = "A simple, theme-synced webcam recorder for Omarchy";
    homepage = "https://github.com/omacom/monologue";
    license = lib.licenses.mit;
    mainProgram = "monologue";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
