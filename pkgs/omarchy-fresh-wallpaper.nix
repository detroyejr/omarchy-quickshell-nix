{
  buildOmarchyPlugin,
  fetchFromGitHub,
}:

buildOmarchyPlugin {
  pname = "omarchy-fresh-wallpaper";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "orienw";
    repo = "omarchy-fresh-wallpaper";
    rev = "dadb4f2709fa5f3de18fcac7e318a6711331a8a0";
    hash = "sha256-h7rNPkrZIrb2kQuf9OE+vuCOD54R414enl6thfcZuWk=";
  };
}
