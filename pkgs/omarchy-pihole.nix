{
  buildOmarchyPlugin,
  fetchFromGitHub,
  python3,
}:

buildOmarchyPlugin {
  pname = "omarchy-pihole";
  version = "0.5.0";
  src = fetchFromGitHub {
    owner = "detroyejr";
    repo = "omarchy-pihole";
    rev = "8177eccf094b1aad74e346e37f04e6f1be33859b";
    hash = "sha256-lFeeo2ohBw9qJymIyvOgCDaJRX48M2n31Tu+FfmjRSk=";
  };
  runtimeInputs = [ python3 ];
}
