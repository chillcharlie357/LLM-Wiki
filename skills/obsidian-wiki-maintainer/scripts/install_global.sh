#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILL_NAME="$(basename "$SKILL_DIR")"
TARGET_ROOT="${1:-${CODEX_HOME:-$HOME/.codex}/skills}"
TARGET_DIR="$TARGET_ROOT/$SKILL_NAME"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TARGET_ROOT"
cp -R "$SKILL_DIR" "$TMP_DIR/$SKILL_NAME"
find "$TMP_DIR/$SKILL_NAME" -name '.DS_Store' -delete
rm -rf "$TARGET_DIR"
mv "$TMP_DIR/$SKILL_NAME" "$TARGET_DIR"

echo "Installed $SKILL_NAME to $TARGET_DIR"

