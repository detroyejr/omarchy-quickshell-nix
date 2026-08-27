{
  buildOmarchyPlugin,
  fetchFromGitHub,
}:

buildOmarchyPlugin {
  pname = "omarchy-lock-explorer";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "SirJul1337";
    repo = "omarchy-lock-explorer";
    rev = "be4458b4e2570bf9a8a468ec5c94201df696d15b";
    hash = "sha256-lWgc/ue7cDkb7wOXAXgZUtHULUSnh0mHfMqY2rDWibA=";
  };
}
