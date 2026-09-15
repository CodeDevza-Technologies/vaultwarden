#!/usr/bin/env bash
# Regenerates branding/web-vault/ from branding/src/ (needs rsvg-convert + ImageMagick `magick`).
# Output paths mirror the web-vault layout so the Dockerfile can COPY the tree over /web-vault.
set -euo pipefail
cd "$(dirname "$0")"
OUT=web-vault; rm -rf "$OUT"; mkdir -p "$OUT/images/icons"
png() { rsvg-convert -w "$2" -h "$3" "$1" -o "$4"; }

cp src/logo.svg       "$OUT/images/logo.svg"
cp src/logo-white.svg "$OUT/images/logo-white.svg"
cp src/icon.svg       "$OUT/images/icon-white.svg"
cp src/icon-mono.svg  "$OUT/images/icons/safari-pinned-tab.svg"

png src/logo.svg       568 122 "$OUT/images/logo-dark@2x.png"
png src/logo-white.svg 568 122 "$OUT/images/logo-white@2x.png"
png src/icon.svg 32 32 "$OUT/images/icon-white.png"
png src/icon.svg 32 32 "$OUT/images/icon-dark.png"

for s in 16 32; do png src/icon.svg $s $s "$OUT/images/icons/favicon-${s}x${s}.png"; done
for s in 192 512; do png src/icon.svg $s $s "$OUT/images/icons/android-chrome-${s}x${s}.png"; done
png src/icon.svg 180 180 "$OUT/images/icons/apple-touch-icon.png"
png src/icon.svg 270 270 "$OUT/images/icons/mstile-150x150.png"
cp "$OUT"/images/icons/*.png "$OUT/images/"          # web-vault ships both locations
png src/icon.svg 48 48 /tmp/_fav48.png
magick "$OUT/images/icons/favicon-16x16.png" "$OUT/images/icons/favicon-32x32.png" /tmp/_fav48.png "$OUT/favicon.ico"
rm -f /tmp/_fav48.png

# Inline logo for the login/landing page: main.js embeds the logo as an SVG string.
# Wordmark paths take the web-vault's theme class (dark text on light, white on dark);
# the mark keeps its brand colours.
sed -e '/<?xml/d' -e '/\.cls-3 {/,/}/d' -e 's/class="cls-3"/class="tw-fill-marketing-logo"/g' src/logo.svg > inline-logo.svg
grep -q 'tw-fill-marketing-logo' inline-logo.svg && ! grep -q '#161616' inline-logo.svg

# Sidebar logos (800x200, same frame the web-vault uses): logo + product subtitle.
# Wordmark and subtitle use the nav foreground class; the mark keeps its colours.
nav_logo() {  # $1 subtitle, $2 output
  {
    echo '<svg version="1.1" viewBox="0 0 800 200" xmlns="http://www.w3.org/2000/svg">'
    echo '  <svg x="0" y="8" width="600" height="129" viewBox="22 201 456 98">'
    sed -e '/<?xml/d' -e '/<svg /d' -e '/<\/svg>/d' -e '/\.cls-3 {/,/}/d' -e 's/class="cls-3"/class="tw-fill-fg-nav"/g' src/logo.svg
    echo '  </svg>'
    echo "  <text x=\"150\" y=\"184\" class=\"tw-fill-fg-nav\" font-family=\"inherit\" font-size=\"38\" font-weight=\"500\">$1</text>"
    echo '</svg>'
  } > "$2"
  grep -q 'tw-fill-fg-nav' "$2" && ! grep -q '#161616' "$2"
}
nav_logo "Password Manager" inline-nav-pm.svg
nav_logo "Admin Console"    inline-nav-admin.svg

# Email header logo (2x for retina, displayed at 190px wide)
png src/logo.svg 380 82 /tmp/_mail-logo.png
base64 -i /tmp/_mail-logo.png | tr -d '\n' > mail-logo.b64
rm -f /tmp/_mail-logo.png
echo "done: $(find "$OUT" -type f | wc -l) files"
