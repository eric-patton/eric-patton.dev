#!/usr/bin/env bash
# Assemble the static site into dist/. The design system lives outside site/ because RequestDesk
# imports the same files, so the build is the only place the two trees are joined.
#
# The contents are cleared rather than the directory itself: a local preview server holds dist/
# open as its working directory, and Windows will not unlink a directory that is in use.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$root/dist"
find "$root/dist" -mindepth 1 -delete
mkdir -p "$root/dist/design-system"
cp -r "$root/site/." "$root/dist/"
cp "$root/design-system/"*.css "$root/dist/design-system/"
echo "built $(find "$root/dist" -type f | wc -l) files into dist/"
