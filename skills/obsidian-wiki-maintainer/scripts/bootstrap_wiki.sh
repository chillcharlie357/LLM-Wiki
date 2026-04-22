#!/bin/zsh
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bootstrap_wiki.sh [--force] <target-dir> [vault-name] [wiki-root] [source-root]

Examples:
  bootstrap_wiki.sh ~/Vaults/MyWiki
  bootstrap_wiki.sh ~/Vaults/MyWiki "Engineering Wiki" docs raw
EOF
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$SCRIPT_DIR/check_dependencies.sh" >/dev/null

append_agent_block() {
  local agent_file="$1"
  local wiki_root="$2"
  local source_root="$3"
  local marker_start="<!-- OBSIDIAN-WIKI-MAINTENANCE:START -->"
  local marker_end="<!-- OBSIDIAN-WIKI-MAINTENANCE:END -->"

  if grep -Fq "$marker_start" "$agent_file"; then
    return 0
  fi

  cat >> "$agent_file" <<EOF

$marker_start
## Obsidian Wiki Maintenance

- \`$wiki_root/\` is the curated reading layer.
- \`$source_root/\` is the source archive for exports, transcripts, and raw notes.
- \`$source_root/assets/\` stores mirrored local attachments.
- Prefer updating existing notes over creating duplicates or empty parent pages.
- Keep \`$wiki_root/index.md\`, \`$wiki_root/log.md\`, \`.canvas\`, \`.base\`, and note links synchronized after moves or merges.
- Prefer \`./qmdw\` for local retrieval when it exists, otherwise fall back to \`qmd\`.
$marker_end
EOF
}

FORCE=0
if [[ "${1:-}" == "--force" ]]; then
  FORCE=1
  shift
fi

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

TARGET_DIR="$1"
VAULT_NAME="${2:-$(basename "$TARGET_DIR")}"
WIKI_ROOT="${3:-wiki}"
SOURCE_ROOT="${4:-raw}"

mkdir -p "$TARGET_DIR"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

AGENT_FILE="$TARGET_DIR/AGENT.md"
INDEX_FILE="$TARGET_DIR/$WIKI_ROOT/index.md"
LOG_FILE="$TARGET_DIR/$WIKI_ROOT/log.md"
RAW_README="$TARGET_DIR/$SOURCE_ROOT/README.md"
QMDW_FILE="$TARGET_DIR/qmdw"
QMD_INDEX="$TARGET_DIR/.config/qmd/index.yml"

if [[ $FORCE -ne 1 ]]; then
  for target_path in "$INDEX_FILE" "$LOG_FILE" "$RAW_README" "$QMDW_FILE" "$QMD_INDEX"; do
    if [[ -e "$target_path" ]]; then
      echo "Refusing to overwrite existing file: $target_path"
      echo "Re-run with --force to replace the standard skeleton files."
      exit 1
    fi
  done
fi

mkdir -p \
  "$TARGET_DIR/$WIKI_ROOT" \
  "$TARGET_DIR/$SOURCE_ROOT/assets" \
  "$TARGET_DIR/.config/qmd" \
  "$TARGET_DIR/.cache/qmd"

if [[ -e "$AGENT_FILE" ]]; then
  append_agent_block "$AGENT_FILE" "$WIKI_ROOT" "$SOURCE_ROOT"
else
  cat > "$AGENT_FILE" <<EOF
<!-- Obsidian wiki maintenance contract template -->

# $VAULT_NAME Maintenance Guide

This vault is maintained as a local Obsidian wiki.

## Structure

- \`$WIKI_ROOT/\` is the curated reading layer.
- \`$SOURCE_ROOT/\` is the source archive for exports, transcripts, and raw notes.
- \`$SOURCE_ROOT/assets/\` stores mirrored local attachments.

## Working Rules

- Prefer updating an existing note over creating duplicates.
- Prefer folders over empty parent pages.
- Keep frontmatter consistent across notes.
- Use wikilinks for internal references.
- Keep large structural updates recorded in \`$WIKI_ROOT/log.md\`.
- Keep \`$WIKI_ROOT/index.md\`, \`.canvas\`, \`.base\`, and note links synchronized after moves or merges.

## Ingest

- Read from \`$SOURCE_ROOT/\` first.
- Preserve \`source\` metadata when a note comes from an external export.
- Convert Notion-style callouts, code blocks, and LaTeX into Obsidian-friendly Markdown.
- Mirror important attachments into \`$SOURCE_ROOT/assets/\`.

## Retrieve

- Prefer \`./qmdw\` when available.
- Fall back to \`qmd\` if no wrapper exists.
- Use \`obsidian read\` when exact vault content matters.

## Lint

After structural or bulk edits, verify:

- frontmatter parses
- wikilinks and embeds resolve
- \`.canvas\` files do not contain stale nodes or dangling edges
- \`.base\` files still match the current structure
- the search index has been refreshed
EOF
fi

cat > "$INDEX_FILE" <<EOF
---
title: index
summary: Top-level navigation page for the wiki.
note_type: moc
area: wiki
topic: navigation
collection: wiki
status: active
migrated_on: '$(date +%F)'
tags:
- area/wiki
- type/moc
- topic/navigation
- collection/wiki
---

# $VAULT_NAME

## Sections

- [[Topic A/Topic A|Topic A]]
- [[Topic B/Topic B|Topic B]]
- [[Foundations/Foundations|Foundations]]

## Operations

- [[log|Maintenance Log]]
EOF

cat > "$LOG_FILE" <<EOF
---
title: log
summary: Chronological record of major wiki maintenance updates.
note_type: log
area: wiki
topic: log
collection: wiki
status: active
migrated_on: '$(date +%F)'
tags:
- area/wiki
- type/log
- topic/log
- collection/wiki
---

# log

## $(date +%F)

- Initialized the vault structure and maintenance files.
- Added the top-level navigation page.
- Prepared local retrieval and lint workflows.
EOF

cat > "$RAW_README" <<EOF
# $SOURCE_ROOT

This directory stores source material for the vault.

## Purpose

- keep exports from external tools
- keep transcripts, drafts, and uncurated notes
- keep mirrored attachments used by curated wiki pages

## Rules

- treat this directory as a source archive, not as the main reading layer
- preserve filenames and folder structure when traceability matters
- avoid large editorial rewrites here; write curated summaries into \`$WIKI_ROOT/\`
- store local images, PDFs, and downloaded files under \`$SOURCE_ROOT/assets/\`
- prefer adding \`source\` metadata in curated notes that originate from files in this directory

## Suggested Layout

- \`$SOURCE_ROOT/exports/\` for bulk exports
- \`$SOURCE_ROOT/notes/\` for raw markdown notes
- \`$SOURCE_ROOT/assets/\` for local attachments
EOF

cat > "$QMDW_FILE" <<'EOF'
#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

export XDG_CONFIG_HOME="$ROOT_DIR/.config"
export XDG_CACHE_HOME="$ROOT_DIR/.cache"
export QMD_CONFIG_DIR="$ROOT_DIR/.config/qmd"
export HF_ENDPOINT="${HF_ENDPOINT:-https://hf-mirror.com}"
export MODEL_ENDPOINT="${MODEL_ENDPOINT:-$HF_ENDPOINT}"

exec qmd "$@"
EOF

cat > "$QMD_INDEX" <<EOF
collections:
  wiki:
    path: $TARGET_DIR/$WIKI_ROOT
    pattern: "**/*.md"
  raw:
    path: $TARGET_DIR/$SOURCE_ROOT
    pattern: "**/*.md"
EOF

touch "$TARGET_DIR/$SOURCE_ROOT/assets/.gitkeep"
chmod +x "$QMDW_FILE"

echo "Initialized Obsidian wiki skeleton in $TARGET_DIR"
