#!/usr/bin/env bash
#
# Assemble and push the AgroCure backend to a Hugging Face Space.
#
# Usage:
#   bash deploy/hf/push_to_space.sh <hf-username> [space-name]
#
# Prereqs (one-time):
#   - Create the Space on huggingface.co (SDK: Docker)
#   - Add OPENAI_API_KEY as a Space secret
#   - git lfs installed   (brew install git-lfs)
#   - Logged in to HF git  (huggingface-cli login  — paste a WRITE token)
#
set -euo pipefail

HF_USER="${1:?Usage: push_to_space.sh <hf-username> [space-name]}"
SPACE="${2:-agrocure-api}"

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
WORK="$ROOT/.hf-space"

echo "▶ Project root: $ROOT"
echo "▶ Target Space: $HF_USER/$SPACE"

rm -rf "$WORK"
git clone "https://huggingface.co/spaces/$HF_USER/$SPACE" "$WORK"

cd "$WORK"
git lfs install
git lfs track "*.pth"

# Sync application code, model weights, and Space config
rsync -a --delete --exclude '__pycache__' "$ROOT/api/"  ./api/
rsync -a --delete --exclude '__pycache__' "$ROOT/src/"  ./src/
mkdir -p checkpoints
rsync -a "$ROOT/checkpoints/"*.pth  checkpoints/ 2>/dev/null || true
rsync -a "$ROOT/checkpoints/"*.json checkpoints/ 2>/dev/null || true
cp "$ROOT/deploy/hf/Dockerfile"        .
cp "$ROOT/deploy/hf/requirements.txt"  .
cp "$ROOT/deploy/hf/README.md"         .

git add -A
git commit -m "Deploy AgroCure API" || echo "ℹ nothing changed"
git push

echo ""
echo "✅ Pushed. The Space is building now."
echo "   Live URL: https://${HF_USER}-${SPACE}.hf.space"
echo "   Point the app at it:"
echo "   flutter run --dart-define=API_URL=https://${HF_USER}-${SPACE}.hf.space"
