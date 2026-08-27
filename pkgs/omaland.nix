{
  buildOmarchyPlugin,
  fetchFromGitHub,
}:

buildOmarchyPlugin {
  pname = "omaland";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "bobby-nicholas";
    repo = "omaland";
    rev = "ec232b6aa2e31b2f089ad89b653cd706989865b9";
    hash = "sha256-BMjrLl4iZfFTZMRiQGh1/D3u+HMjSaRVtKNnvvYbso4=";
  };
}
