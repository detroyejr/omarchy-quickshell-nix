{
  buildOmarchyPlugin,
  curl,
  fetchFromGitHub,
  python3,
}:

buildOmarchyPlugin {
  pname = "omarchy-omapihole";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "BVisagie";
    repo = "omarchy-omapihole";
    rev = "e3a063191f3478bfde6b8aa503bc91ef877238d2";
    hash = "sha256-twOal7vth2yzBZ1nF86SGKR9qTveqqt97CXNMrBchi4=";
  };

  runtimeInputs = [
    curl
    python3
  ];
}
