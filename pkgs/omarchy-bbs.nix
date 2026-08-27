{
  buildOmarchyPlugin,
  fetchFromGitHub,
  python3,
}:

buildOmarchyPlugin {
  pname = "omarchy-bbs";
  version = "0.11.5";

  src = fetchFromGitHub {
    owner = "thoughtlesslabs";
    repo = "omarchy-bbs";
    rev = "800212198bc8a6b604a299bdcc49cd2ad0859293";
    hash = "sha256-tgeyLwwwSsJ71cRTGfRblnfv61M+SsQDFXzaskB3eCo=";
  };

  runtimeInputs = [
    python3
  ];
}
