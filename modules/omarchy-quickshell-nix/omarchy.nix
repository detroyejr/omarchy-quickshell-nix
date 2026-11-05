{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  coreutils,
  quickshell,
  xdg-terminal-exec,
  imagemagick,
  gum,
  python3,
  gtk3,
  procps,
  socat,
  jq,
  lua,
  flock,
  chromium,
  ffmpeg,
  gpu-screen-recorder,
  libxkbcommon,
  mpv,
  slurp,
  gsettings-desktop-schemas,
  glib,
  xdg-utils,
  ttfx,
  uwsm,
  writeText,
  screensaverPackage,
  omasnap,
  titlebarsPackage,
  enableMenu ? false,
  enableBackground ? false,
  extraPlugins ? [ ],
  shellConfig ? "",
  launcherHiddenEntries ? [ ],
}:

let
  version = "4.5.0";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "omarchy";
    rev = "76e11b4f4c031cc9c5291dd5c7115eb2815b765f";
    hash = "sha256-Nk6dSXSCwKGREsO1N1RY/8t5lzZH6Iqptighc5L+GDU=";
  };

  shellConfigFile = writeText "shell.json" "${shellConfig}\n";
  launcherHiddenEntriesFile = writeText "launcher.hides" (
    lib.concatStringsSep "\n" launcherHiddenEntries + "\n"
  );
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
    coreutils
    chromium
    ffmpeg
    flock
    glib
    gpu-screen-recorder
    gsettings-desktop-schemas
    gtk3
    gum
    imagemagick
    jq
    libxkbcommon
    lua
    mpv
    omasnap
    procps
    screensaverPackage
    slurp
    socat
    ttfx
    uwsm
    xdg-terminal-exec
    xdg-utils
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/omarchy" "$out/bin" "$out/share/applications" "$out/share/icons/hicolor/256x256/apps" $out/share/fonts/truetype \
      && cp -r applications bin shell config default themes icon.png icon.txt logo.svg logo.txt "$out/share/omarchy/" \
      && cp -r $out/share/omarchy/default/fonts/omarchy $out/share/fonts/truetype

    substituteInPlace "$out/share/omarchy/shell/plugins/dock/DockWindow.qml" \
      --replace-fail \
      'source: window.dock && appSlot.modelData ? window.dock.iconFor(appSlot.modelData) : ""' \
      'readonly property string requestedIconSource: window.dock && appSlot.modelData ? window.dock.iconFor(appSlot.modelData) : ""
      readonly property string fallbackIconSource: window.dock && window.dock.appLibrary
        ? window.dock.appLibrary.iconSource("application-x-executable")
        : Quickshell.iconPath("application-x-executable", true)
      property bool useFallbackIcon: false
      onRequestedIconSourceChanged: useFallbackIcon = false
      source: useFallbackIcon ? fallbackIconSource : requestedIconSource
      onStatusChanged: {
        if ((status === Image.Error || status === Image.Null) && !useFallbackIcon)
          useFallbackIcon = true
      }'

    substituteInPlace "$out/share/omarchy/default/hypr/workspace-modes.lua" \
      --replace-fail \
      '"/usr/lib/omarchy-hyprland-titlebars/titlebars.so"' \
      '"${titlebarsPackage}/lib/omarchy-hyprland-titlebars/titlebars.so"'

    # These scripts source the shared helper, so bypass its executable wrapper.
    substituteInPlace \
      "bin/omarchy-bar" \
      "bin/omarchy-dock" \
      "$out/share/omarchy/bin/omarchy-bar" \
      "$out/share/omarchy/bin/omarchy-dock" \
      --replace-fail \
      "source omarchy-shell-config" \
      'source "$OMARCHY_PATH/bin/omarchy-shell-config"'

    substituteInPlace \
      "bin/omarchy-launch-about" \
      "$out/share/omarchy/bin/omarchy-launch-about" \
      --replace-fail \
      "source omarchy-branding-about-animation" \
      'source "$OMARCHY_PATH/bin/omarchy-branding-about-animation"'

    substituteInPlace \
      "bin/omarchy-pkg-install" \
      "bin/omarchy-pkg-aur-install" \
      "$out/share/omarchy/bin/omarchy-pkg-install" \
      "$out/share/omarchy/bin/omarchy-pkg-aur-install" \
      --replace-fail \
      "source omarchy-sudo-keepalive" \
      'source "$OMARCHY_PATH/bin/omarchy-sudo-keepalive"'

    substituteInPlace \
      "bin/omarchy-sudo-passwordless" \
      "bin/omarchy-update-stay-awake" \
      "$out/share/omarchy/bin/omarchy-sudo-passwordless" \
      "$out/share/omarchy/bin/omarchy-update-stay-awake" \
      --replace-fail \
      'source "''${security_entrypoint%/*}/omarchy-security-functions" || exit 126' \
      'source "$OMARCHY_PATH/bin/omarchy-security-functions" || exit 126'

    find bin "$out/share/omarchy" -type f -print0 \
      | xargs -0 grep -IlZ -E '(^|[^[:alnum:]_./-])(pgrep|pkill)[[:space:]]' \
      | xargs -0 -r sed -i -E \
        -e 's@(^|[^[:alnum:]_./-])pgrep([[:space:]])@\1${lib.getBin procps}/bin/pgrep\2@g' \
        -e 's@(^|[^[:alnum:]_./-])pkill([[:space:]])@\1${lib.getBin procps}/bin/pkill\2@g'

    # Browser theme scripts source these helpers through OMARCHY_PATH.
    install -d "$out/share/omarchy/install/helpers"
    cp install/helpers/browser-policy.sh install/helpers/as-root.sh \
      "$out/share/omarchy/install/helpers/"

    substituteInPlace "bin/omarchy-theme-set-browser" \
      --replace-fail \
      'source "$OMARCHY_PATH/install/helpers/browser-policy.sh"' \
      "source \"$out/share/omarchy/install/helpers/browser-policy.sh\""

    substituteInPlace "bin/omarchy-theme-set-browser-policy" \
      --replace-fail \
      'PACKAGED_PATH=/usr/bin/omarchy-theme-set-browser-policy' \
      "PACKAGED_PATH=$out/bin/omarchy-theme-set-browser-policy"

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

    substituteInPlace "bin/omarchy-branding-screensaver" \
      --replace-fail \
      'set -euo pipefail' \
      'set -euo pipefail

branding_dir="$HOME/.config/omarchy/branding"
screensaver_asset="$branding_dir/screensaver.txt"

mkdir -p "$branding_dir"'

    substituteInPlace "bin/omarchy-branding-screensaver" \
      --replace-fail \
      '~/.config/omarchy/branding/screensaver.txt' \
      '"$screensaver_asset"'

    for script in \
      "bin/omarchy-sudo-passwordless" \
      "bin/omarchy-security-functions" \
      "$out/share/omarchy/bin/omarchy-sudo-passwordless" \
      "$out/share/omarchy/bin/omarchy-security-functions"; do
      if [[ -f "$script" ]] && grep -qF "/usr/bin/readlink" "$script"; then
        substituteInPlace "$script" \
          --replace-fail \
          "/usr/bin/readlink" \
          "${lib.getBin coreutils}/bin/readlink"
      fi
    done

    substituteInPlace \
      "bin/omarchy-launch-terminal" \
      "bin/omarchy-launch-tui" \
      "bin/omarchy-launch-floating-terminal-with-presentation" \
      "bin/omarchy-remove-launcher-entry" \
      --replace-fail \
      "xdg-terminal-exec" \
      "${lib.getBin xdg-terminal-exec}/bin/xdg-terminal-exec"

    substituteInPlace "bin/omarchy-launch-webapp" \
      --replace-fail \
      'browser="chromium.desktop"' \
      'browser="chromium-browser.desktop"'

    substituteInPlace \
      "$out/share/omarchy/shell/services/AppLibrary.qml" \
      --replace-fail \
      "gtk-launch" \
      "${lib.getBin gtk3}/bin/gtk-launch"


    cp "bin/omarchy-default-agent" "$out/share/omarchy/bin/omarchy-default-agent"

    substituteInPlace \
      "bin/omarchy-default-agent" \
      "$out/share/omarchy/bin/omarchy-default-agent" \
      --replace-fail \
      '  agent_present() { user_install || mise where "$agent_tool" &>/dev/null; }' \
      '  nixpkgs_binary() {
    local binary
    binary=$(command -v "$agent" 2>/dev/null) || return 1
    [[ $(readlink -f "$binary" 2>/dev/null) == /nix/store/* ]]
  }
  agent_present() { nixpkgs_binary || user_install || mise where "$agent_tool" &>/dev/null; }' \
      --replace-fail \
      '  agent_install() {
    user_install && return' \
      '  agent_install() {
    nixpkgs_binary && return
    user_install && return'

    # Invalidate cached keybinding rows when the Lua parser dependency changes.
    substituteInPlace "bin/omarchy-menu-keybindings" \
      --replace-fail "v19" "v20"

    substituteInPlace "bin/omarchy-menu-keybindings" \
      --replace-fail \
      'local config = os.getenv("HOME") .. "/.config/hypr/hyprland.lua"' \
      'local config_home = os.getenv("XDG_CONFIG_HOME")
if not config_home or config_home == "" then
  config_home = (os.getenv("HOME") or "") .. "/.config"
end
local config = config_home .. "/hypr/hyprland.lua"'

    substituteInPlace "bin/omarchy-menu-tmux-keybindings" \
      --replace-fail \
      'config_file="''${TMUX_CONF:-$HOME/.config/tmux/tmux.conf}"' \
      'config_file="''${TMUX_CONF:-''${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf}"'

    find bin \
      -type f \
      -name "omarchy-*" \
      -exec sed -Ei "s,(^| )(omarchy-.*),\\1$out/bin/\\2," "{}" \; \
      && find bin \
      -type f \
      -name "omarchy-*" \
      -exec sed -Ei 's,\~\/.config,''${XDG_CONFIG_HOME-~/.config},' "{}" \; \
      && cp -r bin/* "$out/bin/"

    # The wrapped omarchy-restart-gum uses exec, so it cannot be sourced by
    # the floating-terminal launcher. Source the original helper instead.
    substituteInPlace "$out/bin/omarchy-launch-floating-terminal-with-presentation" \
      --replace-fail \
      "source $out/bin/omarchy-restart-gum" \
      "source $out/share/omarchy/bin/omarchy-restart-gum"

    substituteInPlace "$out/bin/omarchy-launch-shell" \
      --replace-fail "quickshell" "${quickshell}/bin/qs"

    ${lib.optionalString (shellConfig != "") ''
      install -Dm644 ${shellConfigFile} \
        "$out/share/omarchy/config/omarchy/shell.json"
    ''}

    cat ${launcherHiddenEntriesFile} >> "$out/share/omarchy/default/omarchy/launcher.hides"

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
          --run '[ -f /etc/omarchy/install/helpers/browser-policy.sh ] && export OMARCHY_PATH=/etc/omarchy'
      fi
    done

    runHook postInstall
  '';
})
