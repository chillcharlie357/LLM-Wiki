<!-- Obsidian wiki maintenance contract template -->

# {{VAULT_NAME}} Maintenance Guide

This vault is maintained as a local Obsidian wiki.

## Structure

- `{{WIKI_ROOT}}/` is the curated reading layer.
- `{{SOURCE_ROOT}}/` is the source archive for exports, transcripts, and raw notes.
- `{{SOURCE_ROOT}}/assets/` stores mirrored local attachments.

## Working Rules

- Prefer updating an existing note over creating duplicates.
- Prefer folders over empty parent pages.
- Keep frontmatter consistent across notes.
- Treat `summary` as a required frontmatter field for curated notes.
- Keep `summary` to 1-2 sentences and update it when the page meaning changes.
- Use wikilinks for internal references.
- Keep large structural updates recorded in `{{WIKI_ROOT}}/log.md`.
- Keep `{{WIKI_ROOT}}/index.md`, `.canvas`, `.base`, and note links synchronized after moves or merges.

## Ingest

- Read from `{{SOURCE_ROOT}}/` first.
- Preserve `source` metadata when a note comes from an external export.
- Convert Notion-style callouts, code blocks, and LaTeX into Obsidian-friendly Markdown.
- Mirror important attachments into `{{SOURCE_ROOT}}/assets/`.

## Retrieve

- Prefer `./qmdw` when available.
- Fall back to `qmd` if no wrapper exists.
- Use `obsidian read` when exact vault content matters.

## Lint

After structural or bulk edits, verify:

- frontmatter parses
- wikilinks and embeds resolve
- `.canvas` files do not contain stale nodes or dangling edges
- `.base` files still match the current structure
- the search index has been refreshed
