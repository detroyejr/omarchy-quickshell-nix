{
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  hyprland,
  libdrm,
  libinput,
  udev,
  pixman,
  wayland,
  libxkbcommon,
}:

let
  version = "0.3.0";
in
hyprland.stdenv.mkDerivation {
  pname = "omarchy-hyprland-titlebars";
  inherit version;

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "omarchy-hyprland-titlebars";
    tag = "v${version}";
    hash = "sha256-9IvWEwzormNICqCI2V1ss64hes6FNOWFsKc2GcM+6V4=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    hyprland
  ]
  ++ hyprland.buildInputs
  ++ [
    libdrm
    libinput
    udev
    pixman
    wayland
    libxkbcommon
  ];

  meta = {
    description = "Titlebars for Omarchy's floating workspaces";
    homepage = "https://github.com/omacom/omarchy-hyprland-titlebars";
    license = with lib.licenses; [
      bsd3
      mit
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
