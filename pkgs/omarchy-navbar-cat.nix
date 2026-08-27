{
  buildOmarchyPlugin,
  fetchFromGitHub,
  python3,
}:

buildOmarchyPlugin {
  pname = "omarchy-navbar-cat";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "tallsam";
    repo = "omarchy-navbar-cat";
    rev = "6ddd61a6744bab19b04d131ff4f2e087a504ce20";
    hash = "sha256-okqS6KEfK5XaTBmY7D0P7xgbSH476Q8detrXbn70vho=";
  };

  runtimeInputs = [ python3 ];
}
