{
  buildOmarchyPlugin,
  fetchFromGitHub,
}:

buildOmarchyPlugin {
  pname = "omarchy-displaywright";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "BlackKingBarOrg";
    repo = "displaywright-shell-plugin";
    rev = "97878fa394faf8c249d398245aac15eec1be7c2d";
    hash = "sha256-H5x8+IyvlpaAd356PGlOxrKfwG2OalbIgAHNjciG/Qk=";
  };
}
