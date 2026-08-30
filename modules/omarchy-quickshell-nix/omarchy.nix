{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  quickshell,
  xdg-terminal-exec,
  imagemagick,
  gum,
  python3,
  gtk3,
  socat,
  jq,
  flock,
  chromium,
  libxkbcommon,
  gsettings-desktop-schemas,
  glib,
  xdg-utils,
  writeText,
  enableMenu ? false,
  enableBackground ? false,
  extraPlugins ? [ ],
  shellConfig ? "",
}:

let
  version = "unstable-0ae1694";

  src = fetchFromGitHub {
    owner = "basecamp";
    repo = "omarchy";
    rev = "0ae1694830b6bd9511042fe1b89a0062d8c083cb";
    hash = "sha256-yEgF68XAH98choh7B5hXrsMz3A1xW1iPWS95noV61S0=";
  };

  shellConfigFile = writeText "shell.json" "${shellConfig}\n";
  webAppsInstallPhase = import ./webapps.nix { inherit lib; };

in
stdenv.mkDerivation (attrs: {
  pname = "omarchy-quickshell";
  inherit src version;

  buildInputs = [ imagemagick ];
  nativeBuildInputs = [
    makeWrapper
    python3
  ];

  runtimeInputs = [
    flock
    glib
    gsettings-desktop-schemas
    gtk3
    gum
    imagemagick
    jq
    libxkbcommon
    socat
    xdg-terminal-exec
    xdg-utils
    chromium
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/omarchy" "$out/bin" "$out/share/applications" "$out/share/icons/hicolor/256x256/apps" $out/share/fonts/truetype \
      && cp -r applications bin shell config default themes icon.png icon.txt logo.svg logo.txt "$out/share/omarchy/" \
      && cp -r $out/share/omarchy/default/fonts/omarchy $out/share/fonts/truetype
      
    ${lib.optionalString (!enableMenu) ''
      rm -rf "$out/share/omarchy/shell/plugins/menu"
    ''}

    ${lib.optionalString (!enableBackground) ''
      rm -rf "$out/share/omarchy/shell/plugins/background"
    ''}

    # Dropping the omarchy prefix so that we don't sed replace this later.
    substituteInPlace "bin/omarchy-theme-set" \
      --replace-fail \
      'THEME_SET_LOCK="''${XDG_RUNTIME_DIR:-/tmp}/omarchy-theme-set.lock"' \
      'THEME_SET_LOCK="/tmp/theme-set.lock"'

    substituteInPlace "bin/omarchy-dev-font" \
      --replace-fail \
      "#!/usr/bin/python3" \
      "#!${lib.getBin python3}/bin/python3"


    substituteInPlace \
      "bin/omarchy-launch-terminal" \
      "bin/omarchy-launch-tui" \
      "bin/omarchy-launch-screensaver" \
      "bin/omarchy-launch-floating-terminal-with-presentation" \
      "bin/omarchy-remove-launcher-entry" \
      --replace-fail \
      "xdg-terminal-exec" \
      "${lib.getBin xdg-terminal-exec}/bin/xdg-terminal-exec"

    substituteInPlace "bin/omarchy-launch-webapp" \
      --replace-fail \
      "\$(sed -n 's/^Exec=\\([^ ]*\\).*/\\1/p' {~/.local,~/.nix-profile,/usr}/share/applications/\$browser 2>/dev/null | head -1)" \
      "\$(sed -n 's/^Exec=\\([^ ]*\\).*/\\1/p' {~/.local,~/.nix-profile,/usr,/run/current-system/sw}/share/applications/\$browser 2>/dev/null | head -1)" \
      --replace-fail \
      'browser="chromium.desktop"' \
      'browser="chromium-browser.desktop"'

    substituteInPlace \
      "$out/share/omarchy/shell/services/AppLibrary.qml" \
      --replace-fail \
      "gtk-launch" \
      "${lib.getBin gtk3}/bin/gtk-launch"


    # NOTE: Drop mise install instructions.
    sed -i '45,56d' "bin/omarchy-default-agent"

    cp "bin/omarchy-default-agent" "$out/share/omarchy/bin/omarchy-default-agent"

    find bin \
      -type f \
      -name "omarchy-*" \
      -exec sed -Ei "s,(^| )(omarchy-.*),\\1$out/bin/\\2," "{}" \; \
      && find bin \
      -type f \
      -name "omarchy-*" \
      -exec sed -Ei 's,\~\/.config,''${XDG_CONFIG_HOME-~/.config},' "{}" \; \
      && cp -r bin/* "$out/bin/"

    substituteInPlace "$out/bin/omarchy-launch-shell" \
      --replace-fail "quickshell" "${quickshell}/bin/qs"

    ${lib.optionalString (shellConfig != "") ''
      install -Dm644 ${shellConfigFile} \
        "$out/share/omarchy/config/omarchy/shell.json"
    ''}

    ${lib.concatMapStringsSep "\n" (plugin: ''
      install -d "$out/share/omarchy/shell/plugins/${plugin.omarchyPlugin.name}"
      cp -r "${plugin}"/. "$out/share/omarchy/shell/plugins/${plugin.omarchyPlugin.name}"
    '') extraPlugins}

    ${webAppsInstallPhase}

    patchShebangs "$out/bin" "$out/share/omarchy/bin" "$out/share/omarchy/shell"

    for p in "$out"/bin/omarchy-*; do
      chmod +x "$p"
      if [[ -f "$p" && ! -L "$p" ]]; then
        wrapProgram "$p" \
          --set OMARCHY_PATH "$out/share/omarchy" \
          --prefix PATH : "${lib.makeBinPath attrs.runtimeInputs}" \
          --prefix XDG_DATA_DIRS : "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}" \
          --run '[ -d /etc/omarchy ] && export OMARCHY_PATH=/etc/omarchy'
      fi
    done

    runHook postInstall
  '';
})
