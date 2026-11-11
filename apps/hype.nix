{
  fetchFromGitHub,
  ffmpeg,
  lib,
  libwebp,
  qt6,
  sourceHighlight,
  stdenv,
  xdg-desktop-portal,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hype";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "hype";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lDrDfo0LqGbWD8X7rejOYf9nKqyNNZh6wMlL9wRRJoU=";
  };

  nativeBuildInputs = [
    qt6.qtbase
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    ffmpeg
    libwebp
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtimageformats
    qt6.qtmultimedia
    qt6.qtsvg
    sourceHighlight
    xdg-desktop-portal
    zlib
  ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    ./bin/build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 build/hype "$out/bin/hype"
    install -Dm644 pkgbuild/hype.desktop "$out/share/applications/hype.desktop"
    install -Dm644 pkgbuild/hype.svg "$out/share/icons/hicolor/scalable/apps/hype.svg"
    install -Dm644 LICENSE "$out/share/licenses/hype/LICENSE"
    runHook postInstall
  '';

  qtWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      ffmpeg
      sourceHighlight
    ])
  ];

  meta = {
    description = "Simple Markdown presentations with a visual slide editor";
    homepage = "https://github.com/omacom/hype";
    license = lib.licenses.mit;
    mainProgram = "hype";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
