#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BOOTSTRAP="$SKILL_DIR/scripts/bootstrap_wiki.sh"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

FAKE_BIN="$TEST_ROOT/bin"
VAULT="$TEST_ROOT/vault"
mkdir -p "$FAKE_BIN" "$VAULT"

cat > "$FAKE_BIN/obsidian" <<'EOF'
#!/bin/zsh
echo 'Obsidian 1.12.7 (installer 1.12.7)'
EOF
cat > "$FAKE_BIN/qmd" <<'EOF'
#!/bin/zsh
exit 0
EOF
chmod +x "$FAKE_BIN/obsidian" "$FAKE_BIN/qmd"

cat > "$VAULT/AGENTS.md" <<'EOF'
# Existing Project Instructions

Keep this project-specific rule.
EOF

PATH="$FAKE_BIN:$PATH" "$BOOTSTRAP" "$VAULT" "Test Wiki"

[[ -f "$VAULT/AGENTS.md" ]] || {
  echo "Expected bootstrap to create or preserve AGENTS.md" >&2
  exit 1
}
[[ ! -e "$VAULT/AGENT.md" ]] || {
  echo "Bootstrap must not create legacy AGENT.md" >&2
  exit 1
}
grep -Fq '# Existing Project Instructions' "$VAULT/AGENTS.md" || {
  echo "Bootstrap overwrote existing AGENTS.md content" >&2
  exit 1
}
grep -Fq '<!-- OBSIDIAN-WIKI-MAINTENANCE:START -->' "$VAULT/AGENTS.md" || {
  echo "Bootstrap did not append the maintenance contract to AGENTS.md" >&2
  exit 1
}

PATH="$FAKE_BIN:$PATH" "$BOOTSTRAP" --force "$VAULT" "Test Wiki"
[[ "$(grep -Fc '<!-- OBSIDIAN-WIKI-MAINTENANCE:START -->' "$VAULT/AGENTS.md")" == "1" ]] || {
  echo "Bootstrap appended the AGENTS.md maintenance block more than once" >&2
  exit 1
}

echo "AGENTS.md bootstrap behavior verified"
