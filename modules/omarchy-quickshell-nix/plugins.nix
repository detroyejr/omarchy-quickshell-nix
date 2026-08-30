{
  lib,
  stdenv,
  makeWrapper,
}:

args@{
  pname,
  version,
  src,
  patchPhase ? "",
  runtimeInputs ? [ ],
  passthru ? { },
  meta ? { },
  ...
}:

let
  manifestPath = "${src}/manifest.json";
  manifest =
    if builtins.pathExists manifestPath then builtins.fromJSON (builtins.readFile manifestPath) else { };
  pluginId =
    if args ? id then args.id else if manifest ? id then manifest.id else pname;
in
stdenv.mkDerivation {
  inherit
    pname
    version
    src
    meta
    patchPhase
    ;

  nativeBuildInputs = (args.nativeBuildInputs or [ ]) ++ [ makeWrapper ];

  installPhase = ''
    runHook preInstall


    install -d "$out"
    cp -r . "$out"/
    chmod -R u+w "$out"

    runHook postInstall

    patchShebangs "$out"

    ${lib.optionalString (runtimeInputs != [ ]) ''
      runtime_path=${lib.escapeShellArg (lib.makeBinPath runtimeInputs)}
      find $out -type f \( -executable -a \! -iname "*.*" -o -iname "*.sh" \) -print | while IFS= read -r executable; do
        wrapProgram "$executable" --prefix PATH : "$runtime_path"
      done
    ''}
  '';

  passthru = passthru // {
    id = pluginId;
    omarchyPlugin = (passthru.omarchyPlugin or { }) // {
      name = pname;
      id = pluginId;
      inherit runtimeInputs;
    };
  };
}
