{
  alsa-lib,
  cmake,
  fetchFromGitHub,
  fontconfig,
  freetype,
  lib,
  libGL,
  libx11,
  libxcb,
  libxkbcommon,
  llvmPackages,
  openssl,
  pkg-config,
  rustPlatform,
  stdenv,
  vulkan-loader,
  wayland,
  zstd,
}:

let
  version = "0.11.0";
  src = fetchFromGitHub {
    owner = "tobi";
    repo = "disktree";
    tag = "v${version}";
    hash = "sha256-b7VP3VgOS+zUTR2bhOh6JNcN5mIIeHL/fe3u/eHC+X4=";
  };
in
rustPlatform.buildRustPackage {
  pname = "disktree";
  inherit version src;

  cargoLock.lockFile = "${src}/Cargo.lock";
  cargoBuildFlags = [
    "-p"
    "disktree-app"
  ];

  nativeBuildInputs = [
    cmake
    llvmPackages.libclang
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    fontconfig
    freetype
    libGL
    libxkbcommon
    openssl
    vulkan-loader
    wayland
    libx11
    libxcb
    zstd
  ];

  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

  # GPUI's window-harness tests require a graphical session, unavailable in
  # the Nix build sandbox.
  doCheck = false;

  # Do not strip: keep the executable bytes intact, including any appended
  # payloads should upstream add embedded helpers in a future release.
  dontStrip = true;

  dontCargoInstall = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 \
      "target/${stdenv.hostPlatform.rust.rustcTarget}/release/disktree" \
      "$out/bin/disktree"
    install -Dm644 ${src}/assets/disktree.svg \
      "$out/share/icons/hicolor/scalable/apps/disktree.svg"
    install -Dm644 ${src}/LICENSE "$out/share/licenses/disktree/LICENSE"
    install -Dm644 ${src}/packaging/disktree.desktop.in \
      "$out/share/applications/disktree.desktop"
    substituteInPlace "$out/share/applications/disktree.desktop" \
      --replace-fail '@BINDIR@' "$out/bin" \
      --replace-fail '@VERSION@' "${version}"

    runHook postInstall
  '';

  meta = {
    description = "GPUI treemap explorer for disk usage";
    homepage = "https://github.com/tobi/disktree";
    license = lib.licenses.mit;
    mainProgram = "disktree";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
