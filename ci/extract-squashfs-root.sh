#!/bin/sh
set -eu

# Extract a generated AppImage into a squashfs-root-like directory inside dist/
#
# Usage:
#   ./ci/extract-squashfs-root.sh <arch>
#
# Expects: exactly one *.AppImage in current working directory (repo root in CI)

ARCH="${1:-}"
if [ -z "$ARCH" ]; then
  echo "Usage: $0 <arch>" >&2
  exit 2
fi

APPIMAGE="$(ls -1 ./*.AppImage 2>/dev/null | head -n 1 || true)"
if [ -z "$APPIMAGE" ] || [ ! -f "$APPIMAGE" ]; then
  echo "ERROR: cannot find ./*.AppImage (did the build produce one?)" >&2
  exit 1
fi

mkdir -p dist
chmod +x "$APPIMAGE"

# AppImage is an ELF binary; this command extracts the embedded squashfs.
"$APPIMAGE" --appimage-extract

if [ ! -d "squashfs-root" ]; then
  echo "ERROR: extraction finished but ./squashfs-root not found." >&2
  exit 1
fi

OUTDIR="dist/squashfs-root-${ARCH}"
rm -rf "$OUTDIR"
mv "squashfs-root" "$OUTDIR"

tar -C dist -czf "dist/squashfs-root-${ARCH}.tar.gz" "squashfs-root-${ARCH}"

exit 0

