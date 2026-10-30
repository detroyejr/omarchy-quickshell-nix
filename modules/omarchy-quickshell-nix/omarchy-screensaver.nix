{
  lib,
  fetchFromGitHub,
  fontconfig,
  libxkbcommon,
  makeWrapper,
  pkg-config,
  rustPlatform,
}:

let
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "omarchy-screensaver";
    rev = "b3026b63999908bf424eae62194aa95df5e4d24c";
    hash = "sha256-9uvcYUXPExFEUZq2VdvSZz6n2foqiPqyD9CMphgBCTw=";
  };
in
rustPlatform.buildRustPackage {
  pname = "omarchy-screensaver";
  inherit version src;

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes."ttfx-0.5.1" = "sha256-/cECljrthspJsg6fgWMm4QIv8V3FJLuP/pbZoRKFVAc=";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [ libxkbcommon ];

  postInstall = ''
    install -Dm755 "$out/bin/omarchy-launch-screensaver" \
      "$out/lib/omarchy-screensaver/omarchy-screensaver"
    wrapProgram "$out/lib/omarchy-screensaver/omarchy-screensaver" \
      --prefix PATH : "${lib.makeBinPath [ fontconfig ]}"
    ln -s ../lib/omarchy-screensaver/omarchy-screensaver \
      "$out/bin/omarchy-screensaver"
  '';

  meta = {
    description = "Native Wayland screensaver for Omarchy";
    homepage = "https://github.com/omacom/omarchy-screensaver";
    license = lib.licenses.mit;
    mainProgram = "omarchy-screensaver";
    platforms = lib.platforms.linux;
  };
}
