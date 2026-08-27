{
  buildOmarchyPlugin,
  fetchFromGitHub,
}:

buildOmarchyPlugin {
  pname = "omarchy-live-wallpaper";
  version = "3.0.16";

  src = fetchFromGitHub {
    owner = "yesheytenzin";
    repo = "live-wallpaper";
    rev = "92ae4fa71ba16e0c766af75bc1f058e0b3cd3eda";
    hash = "sha256-4JyTBDzQzUkgiI5RBNAyUYgH7R/lKsyQ7WN5aeR52y0=";
  };
}
