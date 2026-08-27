{
  buildOmarchyPlugin,
  fetchFromGitHub,
}:

buildOmarchyPlugin {
  pname = "omarchy-theme-manager";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "mtolhuys";
    repo = "omarchy-theme-manager";
    rev = "5af9ce103055b3d9849b0396146548f7872d0ad9";
    hash = "sha256-2YkZnCPpHzizC/ccZzAmka4DO4LW4ldT5BPMeOAcoNg=";
  };
}
