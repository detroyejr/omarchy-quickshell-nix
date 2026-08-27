{
  buildOmarchyPlugin,
  fetchFromGitHub,
}:

buildOmarchyPlugin {
  pname = "dizziee.auto-wallpaper";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "JJDizz1L";
    repo = "dizziee.auto-wallpaper";
    rev = "c5397646b96eaba45710b32e2dd77a9a4720ddc9";
    hash = "sha256-YDhjgc3nKqY1u9YHo4J3Mi5jkfWkrMohIOqjvLyVzyE=";
  };
}
