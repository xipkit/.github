#!/usr/bin/env bash
# Renders src/profile.html into the light and dark PNGs used by profile/README.md.
# Requires Google Chrome and ImageMagick.
set -euo pipefail

cd "$(dirname "$0")/.."
chrome="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
src="file://$PWD/src/profile.html"
out="profile/assets"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

render() {
  local part=$1 width=$2
  for theme in light dark; do
    local raw="$tmp/$part-$theme.png" dest="$out/$part-$theme.png"
    "$chrome" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=2 \
      --default-background-color=00000000 --virtual-time-budget=8000 \
      --window-size="$width,1400" --screenshot="$raw" "$src?part=$part&theme=$theme" 2>/dev/null
    # Keep the full width so every image scales identically in the README; trim only the empty rows below.
    local h
    h=$(magick "$raw" -alpha extract -bordercolor black -border 1 -trim -format '%[fx:page.y+h-1]' info:)
    magick "$raw" -crop "$((width * 2))x${h}+0+0" +repage -strip "$dest"
    echo "$dest"
  done
}

render hero 880
render xip 432
render rip 432
render oss 880
render believe 880
