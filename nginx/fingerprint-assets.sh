#!/bin/sh
#
# Rewrite every locally referenced asset URL in the built site to carry a ?v=<content hash>.
#
# Why this exists: the stylesheets and images live at stable paths, so a browser that visited an
# earlier release will happily pair freshly fetched HTML with a stale stylesheet until its cache
# expires. That is not hypothetical. This site shipped a front page that looked broken for exactly
# that reason: new markup, previous release's CSS, and nothing in the response to tell the browser
# they no longer belonged together.
#
# Changing a file now changes its URL, so no cache anywhere can pair the wrong two versions. The
# HTML itself is served no-cache (nginx/default.conf), because it is what carries the hashes.
#
# Order matters. Images are hashed into both the HTML and the stylesheets first, because a
# stylesheet's own hash has to be taken after its contents are final; doing it the other way round
# would publish a stylesheet hash that no longer matches the file being served.
#
# Runs once at image build time against the unpacked web root. POSIX sh: this is the nginx alpine
# image, where the shell is busybox.
set -eu

root="${1:-/usr/share/nginx/html}"

# Rewrite "$1" (an absolute site path) to "$1?v=<hash>" everywhere in the files matching "$2".
stamp_into() {
  rel="$1"
  glob="$2"
  hash="$(md5sum "${root}${rel}" | cut -c1-10)"

  # Only "." needs escaping for the search: "|" is the sed delimiter, so slashes stay literal.
  pattern="$(printf '%s' "$rel" | sed 's/\./\\./g')"

  find "$root" -type f -name "$glob" -exec \
    sed -i "s|\"${pattern}\"|\"${rel}?v=${hash}\"|g" {} +
}

images="$(find "$root" -type f \
  \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.svg' -o -name '*.webp' \))"

# Pass 1: images, into both the markup and the stylesheets that reference them.
echo "$images" | while IFS= read -r file; do
  [ -n "$file" ] || continue
  rel="${file#"$root"}"
  stamp_into "$rel" '*.html'
  stamp_into "$rel" '*.css'
done

# Pass 2: stylesheets, into the markup, now that their contents are settled.
find "$root" -type f -name '*.css' | while IFS= read -r file; do
  rel="${file#"$root"}"
  stamp_into "$rel" '*.html'
done

echo "fingerprinted $(echo "$images" | grep -c .) images and $(find "$root" -name '*.css' | wc -l) stylesheets"
