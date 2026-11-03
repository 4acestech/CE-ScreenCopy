#!/usr/bin/env bash
# Builds CE-ScreenCopy.app (if it isn't built yet) and packs it into CE-ScreenCopy.dmg
# (drag-to-Applications installer).   Paste-and-run:   bash make_dmg.sh        (add --rebuild to force a fresh build)
set -euo pipefail
cd "$(dirname "$0")"

APP="CE-ScreenCopy.app"
VOL="CE-ScreenCopy"
DMG="CE-ScreenCopy.dmg"

command -v hdiutil >/dev/null || { echo "hdiutil not found - this script has to be run on a Mac."; exit 1; }

if [ "${1:-}" = "--rebuild" ] || [ ! -d "$APP" ]; then
  bash build.sh
fi
[ -d "$APP" ] || { echo "Build failed: $APP not found."; exit 1; }

STAGE_ROOT="$(mktemp -d)"
STAGE="$STAGE_ROOT/$VOL"
mkdir -p "$STAGE"
trap 'rm -rf "$STAGE_ROOT"' EXIT

cp -R "$APP" "$STAGE/"
xattr -cr "$STAGE/$APP" 2>/dev/null || true
ln -s /Applications "$STAGE/Applications"
cat > "$STAGE/READ ME FIRST.txt" <<'TXT'
CE-ScreenCopy  -  made by @4acestech  (tiktok.com/@4acestech)

Install:  drag CE-ScreenCopy into the Applications folder.

First launch:  right-click CE-ScreenCopy > Open > Open (the app is ad-hoc signed, not notarized).
Then click "Grant Permissions..." and allow:
  - Screen Recording   (to mirror your screen to the calculator)
  - Accessibility      (so calculator keys can type / move the mouse)
Quit and reopen the app once after granting.

TI-84 Plus CE : run CALC2KEY on the calculator.
Casio fx-CG   : install CGVirtMo.g3a on the calculator and open "Virt Monitor".
TXT

rm -f "$DMG"
hdiutil create -volname "$VOL" -srcfolder "$STAGE" -fs HFS+ -format UDZO -imagekey zlib-level=9 -ov "$DMG" >/dev/null
codesign --force --sign - "$DMG" >/dev/null 2>&1 || true

echo
echo "Built $DMG  ($(du -h "$DMG" | cut -f1))"
echo "Open it, drag CE-ScreenCopy onto Applications, then right-click > Open the first time."
