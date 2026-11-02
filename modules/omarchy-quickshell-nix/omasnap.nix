{
  cmake,
  fetchFromGitHub,
  hyprland,
  kdePackages,
  lib,
  libdeflate,
  ninja,
  pkg-config,
  qt6,
  stdenv,
  tesseract,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wl-clipboard,
  xdg-utils,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "omasnap";
  version = "1.24.0";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "omasnap";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ntlb7Nwrg7nuvBsTsbv9Va3TOSyPLqzEimP4tGb5rAE=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "/usr/share/wayland-protocols" "${wayland-protocols}/share/wayland-protocols"
  '';

  nativeBuildInputs = [
    cmake
    kdePackages.layer-shell-qt
    ninja
    pkg-config
    qt6.wrapQtAppsHook
    wayland-scanner
  ];

  buildInputs = [
    kdePackages.layer-shell-qt
    libdeflate
    qt6.qtbase
    qt6.qtwayland
    wayland
    wayland-protocols
  ];

  cmakeFlags = [ (lib.cmakeBool "BUILD_TESTING" false) ];

  qtWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      hyprland
      tesseract
      wl-clipboard
      xdg-utils
    ])
  ];

  meta = {
    description = "Native Wayland screenshot and annotation overlay for Omarchy and Hyprland";
    homepage = "https://github.com/omacom/omasnap";
    license = lib.licenses.mit;
    mainProgram = "omasnap";
    platforms = lib.platforms.linux;
  };
})
