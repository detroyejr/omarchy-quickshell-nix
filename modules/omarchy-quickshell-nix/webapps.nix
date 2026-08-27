{ lib }:

''
  safe_icon_name() {
    printf '%s\n' "$1" \
      | tr '[:upper:]' '[:lower:]' \
      | sed 's/[^[:alnum:]]\+/-/g; s/^-//; s/-$//'
  }

  for icon in "$out/share/omarchy/applications/icons"/*.png; do
    icon_name=$(basename "$icon" .png)
    install -Dm644 "$icon" "$out/share/icons/hicolor/256x256/apps/$(safe_icon_name "$icon_name").png"
  done

  for desktop in "$out/share/omarchy/applications"/*.desktop; do
    if grep -qE '^Exec=(omarchy-launch-webapp|omarchy-webapp-handler)' "$desktop"; then
      target="$out/share/applications/$(basename "$desktop")"
      cp "$desktop" "$target"
      sed -Ei "s,^Exec=(omarchy-[^ ]+),Exec=$out/bin/\\1," "$target"
    fi
  done
''
