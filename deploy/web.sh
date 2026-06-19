#!/usr/bin/env bash
#
# Build the Flutter web app and deploy it to the Hugging Face static Space.
# Usage: bash deploy/web.sh
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/agrocure_app"
WEB="$ROOT/.hf-web"
API_URL="https://vKhaled02-agrocure-api.hf.space"
SPACE="https://huggingface.co/spaces/vKhaled02/agrocure"

echo "▶ Building web (API_URL=$API_URL)"
( cd "$APP" && flutter build web --release --dart-define=API_URL="$API_URL" )

if [ ! -d "$WEB/.git" ]; then
  rm -rf "$WEB"
  git clone "$SPACE" "$WEB"
fi

echo "▶ Syncing build → Space"
# wipe old app files but keep git, README, and the LFS rules
find "$WEB" -mindepth 1 -maxdepth 1 \
  ! -name '.git' ! -name 'README.md' ! -name '.gitattributes' -exec rm -rf {} +
cp -R "$APP/build/web/." "$WEB/"

# HF requires .wasm binaries in git-lfs
git -C "$WEB" lfs install >/dev/null 2>&1 || true
printf '*.wasm filter=lfs diff=lfs merge=lfs -text\n*.bin filter=lfs diff=lfs merge=lfs -text\n' > "$WEB/.gitattributes"

git -C "$WEB" add -A
git -C "$WEB" commit -q -m "Deploy AgroCure PWA" || echo "ℹ nothing changed"
git -C "$WEB" push -q

echo "✅ Live: https://vkhaled02-agrocure.static.hf.space"
