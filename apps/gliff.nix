{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  nasm,
  makeWrapper,
  dbus,
  gtk4,
  hicolor-icon-theme,
  libadwaita,
  libdrm,
  libgbm,
  libva,
  libxkbcommon,
  mesa,
  openssh,
  vulkan-loader,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gliff";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "gliff";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SUvnAxmXyBqPrtgBfEp06/KHlO0m2OtaP+lVaFgK04M=";
  };

  cargoLock.lockFile = "${finalAttrs.src}/Cargo.lock";

  nativeBuildInputs = [
    makeWrapper
    nasm
    pkg-config
  ];

  buildInputs = [
    dbus
    gtk4
    hicolor-icon-theme
    libadwaita
    libdrm
    libgbm
    libva
    libxkbcommon
    mesa
    openssh
    vulkan-loader
    wayland
  ];

  buildPhase = ''
    runHook preBuild
    cargo build --release --locked --offline
    runHook postBuild
  '';

  dontCargoInstall = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 target/release/gliff "$out/bin/gliff"
    install -Dm755 target/release/gliff-server "$out/bin/gliff-server"
    install -Dm755 target/release/gliff-probe "$out/bin/gliff-probe"
    install -Dm644 ${finalAttrs.src}/LICENSE "$out/share/licenses/gliff/LICENSE"
    install -Dm644 ${finalAttrs.src}/NOTICE "$out/share/licenses/gliff/NOTICE"
    install -Dm644 ${finalAttrs.src}/pkgbuild/gliff.desktop \
      "$out/share/applications/gliff.desktop"
    install -Dm644 ${finalAttrs.src}/pkgbuild/gliff.svg \
      "$out/share/icons/hicolor/scalable/apps/gliff.svg"
    install -Dm644 ${finalAttrs.src}/README.md "$out/share/doc/gliff/README.md"
    install -Dm644 ${finalAttrs.src}/docs/hardware-quirks.md \
      "$out/share/doc/gliff/hardware-quirks.md"

    wrapProgram "$out/bin/gliff" \
      --prefix PATH : "${lib.makeBinPath [ openssh ]}"

    runHook postInstall
  '';

  meta = {
    description = "Hyprland remote desktop over SSH with GPU-accelerated H.264";
    homepage = "https://github.com/omacom/gliff";
    license = with lib.licenses; [
      mit
      bsd2
    ];
    mainProgram = "gliff";
    platforms = [ "x86_64-linux" ];
  };
})
