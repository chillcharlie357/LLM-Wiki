# {{SOURCE_ROOT}}

This directory stores source material for the vault.

## Purpose

- keep exports from external tools
- keep transcripts, drafts, and uncurated notes
- keep mirrored attachments used by curated wiki pages

## Rules

- treat this directory as a source archive, not as the main reading layer
- preserve filenames and folder structure when traceability matters
- avoid large editorial rewrites here; write curated summaries into `{{WIKI_ROOT}}/`
- store local images, PDFs, and downloaded files under `{{SOURCE_ROOT}}/assets/`
- prefer adding `source` metadata in curated notes that originate from files in this directory

## Suggested Layout

- `{{SOURCE_ROOT}}/exports/` for bulk exports
- `{{SOURCE_ROOT}}/notes/` for raw markdown notes
- `{{SOURCE_ROOT}}/assets/` for local attachments

## Typical Flow

1. ingest or export documents into `{{SOURCE_ROOT}}/`
2. read and normalize the source material
3. write or update curated notes in `{{WIKI_ROOT}}/`
4. preserve attachment links through `{{SOURCE_ROOT}}/assets/`

