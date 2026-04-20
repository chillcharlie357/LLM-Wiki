---
name: obsidian-wiki-maintainer
description: "Use when maintaining a local Obsidian wiki: create or reorganize notes and folders, ingest or update content from source archives, retrieve knowledge with qmd or a local wrapper, and run health checks for frontmatter, links, canvas/base sync, index or log updates, and search index refresh."
---

# Obsidian Wiki Maintainer

## Overview

Maintain an Obsidian knowledge base as a durable local wiki, not as a loose collection of notes. Prefer a curated reading layer, a separate source archive, synchronized navigation files, and a stable local retrieval command.

## Dependencies

This skill assumes these tools are available:

- `obsidian` CLI for reading, creating, searching, and validating vault content
- `qmd` for local full-text and vector-backed retrieval
- optional `./qmdw` wrapper to keep `qmd` config and cache local to the vault

If `obsidian` or `qmd` is missing, install or configure them before relying on the retrieve or lint workflow.
On first use, verify the Obsidian installer version, CLI registration, and terminal PATH setup using the official [Obsidian CLI troubleshooting guide](https://obsidian.md/help/cli#Troubleshooting).

## Recommended Conventions

Adapt to the current vault first. If the vault already has conventions, preserve them. If it does not, prefer these defaults:

- `wiki/` for curated notes
- `raw/` for source exports, transcripts, and attachments
- `raw/assets/` for downloaded or mirrored local files
- `wiki/index.md` for top-level navigation
- `wiki/log.md` for major maintenance updates
- `wiki/map.canvas` for the visual map
- `wiki/wiki.base` for structured note views
- `./qmdw` as the preferred local retrieval wrapper when it exists

## Standard Templates

This skill ships with reusable templates:

- [`templates/AGENT.md`](templates/AGENT.md) for the vault maintenance contract
- [`templates/raw/README.md`](templates/raw/README.md) for the source archive contract
- [`templates/raw/assets/.gitkeep`](templates/raw/assets/.gitkeep) to preserve the local attachments directory
- [`templates/wiki/index.md`](templates/wiki/index.md) for the navigation page
- [`templates/wiki/log.md`](templates/wiki/log.md) for the maintenance log
- [`templates/qmdw`](templates/qmdw) for the local `qmd` wrapper
- [`templates/.config/qmd/index.yml`](templates/.config/qmd/index.yml) for `qmd` collections

Use placeholders such as `{{VAULT_NAME}}`, `{{WIKI_ROOT}}`, and `{{SOURCE_ROOT}}`, then adapt them to the target vault.

## Bundled Scripts

- [`scripts/check_dependencies.sh`](scripts/check_dependencies.sh) verifies `obsidian`, `qmd`, Obsidian installer version, and CLI registration hints before first use
- [`scripts/install_global.sh`](scripts/install_global.sh) installs this skill into the global Codex skills directory
- [`scripts/bootstrap_wiki.sh`](scripts/bootstrap_wiki.sh) initializes a new Obsidian wiki with the standard structure, templates, and local `qmdw` wrapper

Use the bootstrap script when setting up a new vault from scratch instead of copying files manually.
If the target already has an `AGENT.md`, the bootstrap script appends a dedicated Obsidian wiki maintenance block instead of overwriting the file.

## Detect Before Editing

Before making changes:

1. Detect the curated notes root. Prefer an existing `wiki/` directory, otherwise use the vault's established notes layout.
2. Detect the source archive location. Prefer `raw/` when present.
3. Detect whether the vault already uses:
   - `index.md`
   - `log.md`
   - `.canvas`
   - `.base`
   - `qmdw` or plain `qmd`
4. Reuse existing frontmatter keys before inventing a new schema.
5. Preserve the vault's folder taxonomy unless it is clearly broken.

## Workflow

### 1. Create Wiki Content

Use this path when the task is to create a new note, theme directory, or local wiki structure.

1. Inspect the curated notes root first and avoid creating duplicate notes.
2. Prefer shallow directories over Notion-style empty parent pages.
3. Place the note in the most specific existing folder.
4. Add consistent frontmatter at the top:
   - `title`
   - `source` when a raw source exists
   - `source_type`
   - `note_type`
   - `area`
   - `topic`
   - `collection`
   - `parent_note` when applicable
   - `status`
   - `migrated_on`
5. Add or update the relevant entry in the navigation page if the vault has one.
6. If the new note changes structure meaningfully, update the `.canvas` and `.base` files when they exist.
7. Record the change in the maintenance log when the vault has one.

### 2. Insert Or Update Content

Use this path when the task is to ingest raw material, enrich an existing note, or merge conversation output into the wiki.

1. Read the relevant source archive first.
2. Prefer updating an existing wiki note over creating a new one.
3. Preserve traceability:
   - keep `source`
   - keep attachments under a dedicated assets directory
   - do not rewrite the source archive into a curated reading layer
4. Convert content into Obsidian-friendly Markdown:
   - wikilinks for internal notes
   - callouts instead of Notion asides
   - fenced code blocks with languages
   - `$...$` and `$$...$$` for LaTeX
5. If a file move or merge happens, update all affected wikilinks and `parent_note` values.
6. Append a concise maintenance entry to the log when one exists.

### 3. Retrieve Existing Knowledge

Use this path when answering questions from the current knowledge base or looking for source material before editing.

Default command order when a wrapper such as `./qmdw` exists:

```bash
./qmdw query "<question>"
./qmdw search "<keywords>" -c wiki
./qmdw get "<qmd://...>"
./qmdw ls wiki
```

Fallback command order when only `qmd` exists:

```bash
qmd query "<question>"
qmd search "<keywords>"
qmd get "<qmd://...>"
qmd ls
```

Rules:

- Prefer a local wrapper such as `./qmdw` over raw `qmd` when the project provides one.
- Search curated notes first, then source archives if you need original context.
- After locating a target, use `obsidian read` or file reads for exact content.
- If the answer produces durable structure, write it back into the wiki rather than leaving it only in chat.

### 4. Lint The Wiki

Use this path after structural edits, migrations, or bulk formatting work.

Check these invariants:

- all Markdown frontmatter parses
- no broken wikilinks or embeds in curated notes
- no stale file nodes or dangling edges in `.canvas` files
- the navigation page matches the current folder structure
- `.base` files are still valid after moves or renames
- the local search index refresh runs cleanly
- if the search tool reports pending vectors, run the embedding refresh

Typical command sequence with `qmdw`:

```bash
./qmdw update
./qmdw status
./qmdw embed
obsidian read path='wiki/index.md'
```

Typical command sequence with plain `qmd`:

```bash
qmd update
qmd status
qmd embed
```

If you move or rename notes, always lint before considering the task complete.

## Non-Negotiable Rules

- Do not create empty parent pages just to mimic Notion nesting.
- Prefer directory structure over duplicate “jump” notes.
- Treat the source archive as source material, not as the curated reading layer.
- Keep major changes logged when the vault maintains a log.
- Keep `index.md`, `.canvas`, `.base`, and note links synchronized after structure changes.
- Prefer durable wiki pages over one-off chat-only summaries.

## Completion Checklist

- target note or folder created/updated
- navigation updated where needed
- structural files synchronized if paths changed
- search index refreshed
- embeddings refreshed when hashes changed
- maintenance log updated for substantial work when present
