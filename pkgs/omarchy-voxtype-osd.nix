{
  buildOmarchyPlugin,
  fetchFromGitHub,
}:

buildOmarchyPlugin {
  pname = "omarchy-voxtype-osd";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Blizl";
    repo = "Omarchy-Voxtype-OSD";
    rev = "e7a0eb40800e0395d8f56d0aa4d8e3372a8b88e3";
    hash = "sha256-8A5LkCQ6VHFivE23w67AJltIYeAjuzA03klHlL2QHFo=";
  };
}
