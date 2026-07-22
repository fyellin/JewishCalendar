#!/bin/zsh
# Updates the Hebrew year shown on all app icons.
#
#   Usage:  ./update-icon-year.sh 5788
#
# Rewrites every size in Assets.xcassets/AppIcon.appiconset, plus the
# Jewish_Calendar_ver-<year>.icns and .png files in this folder.
# See fixicon.swift for how the year is drawn.

set -e
YEAR="$1"
if [[ -z "$YEAR" ]]; then
    echo "Usage: $0 <new-hebrew-year>   e.g. $0 5788"
    exit 1
fi

cd "$(dirname "$0")"
ICONSET_DIR="../Assets.xcassets/AppIcon.appiconset"
MASTER="$ICONSET_DIR/Icon_512x512@2x.png"    # 1024x1024

# 1. Replace the year on the 1024px master.
swift fixicon.swift "$MASTER" /tmp/icon_master.png "$YEAR"
cp /tmp/icon_master.png "$MASTER"
cp /tmp/icon_master.png "$ICONSET_DIR/Icon_iOS_1024.png"
# The App Store rejects iOS icons with an alpha channel (the Mac ones keep theirs).
swift flatten_alpha.swift "$ICONSET_DIR/Icon_iOS_1024.png"

# 2. Regenerate every smaller size from the master.
sips -z 512 512 /tmp/icon_master.png --out "$ICONSET_DIR/Icon_512x512.png" > /dev/null
sips -z 256 256 /tmp/icon_master.png --out "$ICONSET_DIR/Icon_256x256.png" > /dev/null
sips -z 128 128 /tmp/icon_master.png --out "$ICONSET_DIR/Icon_128x128.png" > /dev/null
sips -z 64 64 /tmp/icon_master.png --out "$ICONSET_DIR/Icon_32x32@2x.png" > /dev/null
sips -z 32 32 /tmp/icon_master.png --out "$ICONSET_DIR/Icon_32x32.png" > /dev/null
sips -z 16 16 /tmp/icon_master.png --out "$ICONSET_DIR/Icon_16x16.png" > /dev/null
cp "$ICONSET_DIR/Icon_512x512.png" "$ICONSET_DIR/Icon_256x256@2x.png"
cp "$ICONSET_DIR/Icon_256x256.png" "$ICONSET_DIR/Icon_128x128@2x.png"
cp "$ICONSET_DIR/Icon_32x32.png" "$ICONSET_DIR/Icon_16x16@2x.png"

# 3. Rebuild the .icns and the 512px source PNG in this folder.
swift fixicon.swift Jewish_Calendar_ver-*.png /tmp/icon_512.png "$YEAR"
rm Jewish_Calendar_ver-*.png
cp /tmp/icon_512.png "Jewish_Calendar_ver-$YEAR.png"

TMP_ICONSET=$(mktemp -d)/app.iconset
mkdir -p "$TMP_ICONSET"
for size in 16 32 128 256 512; do
    cp "$ICONSET_DIR/Icon_${size}x${size}.png" "$TMP_ICONSET/icon_${size}x${size}.png"
    cp "$ICONSET_DIR/Icon_${size}x${size}@2x.png" "$TMP_ICONSET/icon_${size}x${size}@2x.png"
done
rm -f Jewish_Calendar_ver-*.icns
iconutil -c icns "$TMP_ICONSET" -o "Jewish_Calendar_ver-$YEAR.icns"

echo "Done: all icons now show $YEAR."
