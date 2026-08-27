{
  buildOmarchyPlugin,
  fetchFromGitHub,
}:

buildOmarchyPlugin {
  pname = "omarchy-theme-scheduler";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "acrogenesis";
    repo = "omarchy-theme-scheduler";
    rev = "54c2f0a83b9da6b1a81abb80a06728dc6b2e8003";
    hash = "sha256-5dMveDF6EyJc/zPD1jlms34sHMKijfLl6WzIgtC15kk=";
  };
}
