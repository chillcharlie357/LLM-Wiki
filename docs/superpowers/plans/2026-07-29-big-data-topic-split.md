# Big Data Topic Split Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Split the single big-data guide into a navigable MOC plus five learning/interview topic notes, grounded in multi-format raw material and enriched with Obsidian-native visualizations.

**Architecture:** Keep `wiki/大数据/00-大数据.md` as a substantive MOC and place five focused children in the same folder. Each child owns one coherent concept boundary, links back to the MOC, cites source files, and contains Mermaid and selected raw-image embeds; the global Canvas mirrors the same hub-and-spoke model.

**Tech Stack:** Obsidian Markdown and wikilinks, Mermaid, JSON Canvas 1.0, Obsidian Bases YAML, MinerU extraction, qmd local index, Git/GitHub.

---

### Task 1: Establish multi-format source coverage

**Files:**
- Read: `raw/Big-Data-Theory-and-Practice/courses/chapter02/第02讲-分布式协调服务Zookeeper.pdf`
- Read: `raw/Big-Data-Theory-and-Practice/courses/chapter05/第04讲-分布式计算框架MapReduce.pdf`
- Read: `raw/Big-Data-Theory-and-Practice/courses/chapter08/2. Parquet 文件格式深入解析.pptx`
- Read: `raw/Big-Data-Theory-and-Practice/courses/chapter11/第11讲-分布式流处理框架Flink.pdf`
- Read: `raw/Big-Data-Theory-and-Practice/paper/Armbrust 等 - 2021 - Lakehouse A New Generation of Open Platforms that.pdf`

- [ ] **Step 1: Inventory raw formats**

Run:

```bash
rg --files raw/Big-Data-Theory-and-Practice | awk -F. 'NF>1 {count[tolower($NF)]++} END {for (ext in count) print ext, count[ext]}' | sort
```

Expected: output includes `md`, `pdf`, `pptx`, image formats, source code and configuration formats.

- [ ] **Step 2: Extract representative non-Markdown sources**

Run `mineru-open-api flash-extract` on pages 1–10 of the five files listed above, using `--language ch` and a temporary output directory inside the checkout.

Expected: five Markdown extraction files, covering coordination, batch processing, columnar storage, stream processing and lakehouse architecture.

- [ ] **Step 3: Inspect original diagrams and practice code**

Inspect these files before writing:

```text
raw/Big-Data-Theory-and-Practice/courses/chapter05/mapreduce-flow.png
raw/Big-Data-Theory-and-Practice/courses/chapter08/dremel.png
raw/Big-Data-Theory-and-Practice/courses/chapter09/bigtable.jpg
raw/Big-Data-Theory-and-Practice/courses/chapter11/etl-process-explained-diagram.png
raw/Big-Data-Theory-and-Practice/courses/chapter11/辅助材料/lambda vs kappa.jpg
raw/Big-Data-Theory-and-Practice/courses/chapter10/examples/scenario3_exactly_once/README.md
raw/Big-Data-Theory-and-Practice/courses/chapter11/hands-on-streaming/README.md
```

Expected: the curated notes use claims and diagrams that can be traced to these source artifacts.

### Task 2: Build the MOC and five focused topic notes

**Files:**
- Modify: `wiki/大数据/00-大数据.md`
- Create: `wiki/大数据/01-分布式协调与存储.md`
- Create: `wiki/大数据/02-批处理与资源调度.md`
- Create: `wiki/大数据/03-SQL 分析与湖仓.md`
- Create: `wiki/大数据/04-消息队列与流处理.md`
- Create: `wiki/大数据/05-大数据面试与系统设计.md`

- [ ] **Step 1: Rewrite the MOC**

Set `note_type: moc`; retain the title, aliases and traceability fields. Include the 4V-to-engineering-constraints table, a Mermaid stack map, five topic links, a Mermaid learning mind map, and a compact staged learning path.

- [ ] **Step 2: Write the coordination and storage note**

Cover CAP/BASE, ZooKeeper session/ZNode/watch/quorum, HDFS NameNode/DataNode read-write paths, HBase WAL/MemStore/HFile/compaction, workload boundaries, failure modes and interview prompts. Add three Mermaid diagrams and embed `bigtable.jpg`.

- [ ] **Step 3: Write the batch and scheduling note**

Cover MapReduce split/map/shuffle/reduce, YARN RM/NM/AM/Container, Spark RDD/DataFrame/DAG/stage, workload comparison, bottleneck diagnosis and interview prompts. Add three Mermaid diagrams and embed `mapreduce-flow.png`.

- [ ] **Step 4: Write the SQL and lakehouse note**

Cover Hive metadata/partition/bucket, row-versus-column storage, Parquet row groups/pages/encoding, warehouse/lake/lakehouse trade-offs, Iceberg metadata/snapshots/commit and file lifecycle. Add four Mermaid diagrams and embed `dremel.png`.

- [ ] **Step 5: Write the messaging and streaming note**

Cover Kafka partitions, consumer groups, delivery semantics, Flink event time/watermarks/windows/state/checkpoints/backpressure, end-to-end exactly-once boundaries, Lambda/Kappa and practice scenarios. Add four Mermaid diagrams and embed the ETL and Lambda/Kappa images.

- [ ] **Step 6: Write the interview and system-design note**

Cover a shared comparison matrix, a selection decision tree, the scenario-mechanism-trade-off-failure answer pattern, a real-time metrics platform data flow, observability, capacity estimation, failure diagnosis and a four-stage learning roadmap. Add three Mermaid diagrams and link every question to its topic note.

### Task 3: Synchronize navigation surfaces

**Files:**
- Modify: `wiki/index.md`
- Modify: `wiki/log.md`
- Modify: `wiki/wiki.base`
- Modify: `wiki/map.canvas`

- [ ] **Step 1: Expand the home navigation**

Keep `[[wiki/大数据/00-大数据|大数据]]` as the primary entry and add links to all five child notes under the same heading.

- [ ] **Step 2: Update Base views**

Add `parent_note` to the `大数据` table order and add `wiki/大数据/00-大数据.md` to the MOC card filter. Preserve valid YAML and the existing folder formula.

- [ ] **Step 3: Expand the Canvas mind map**

Resize the existing 大数据 group; add five 16-character hex file-node IDs with non-overlapping positions; connect the MOC to each child using five unique edge IDs and descriptive labels.

- [ ] **Step 4: Record the maintenance event**

Replace the existing 2026-07-29 log entry with a description of the six-page structure, MinerU review of PDF/PPTX/papers, local image reuse, Mermaid additions and Canvas expansion.

### Task 4: Validate the Obsidian wiki and search index

**Files:**
- Validate: `wiki/**/*.md`
- Validate: `wiki/wiki.base`
- Validate: `wiki/map.canvas`

- [ ] **Step 1: Validate Markdown metadata and links**

Run a Ruby script using `YAML.safe_load` to parse every wiki frontmatter, assert non-empty `summary`, and resolve every `[[...]]` target after removing aliases, headings and block references.

Expected: all notes parse, all summaries are non-empty and no wiki links are unresolved.

- [ ] **Step 2: Validate diagrams and structural files**

Run JSON validation for Canvas ID uniqueness, edge endpoints, file-node existence and node overlap inside the 大数据 group. Run YAML validation for Base formulas, filters and views. Check all changed Markdown files for balanced fenced blocks and Mermaid blocks.

Expected: zero malformed structures, zero dangling edges, zero missing files and zero overlapping 大数据 nodes.

- [ ] **Step 3: Refresh and query qmd**

Run:

```bash
./qmdw sync
./qmdw status
./qmdw search "ZooKeeper HDFS HBase" -c wiki --files
./qmdw search "MapReduce YARN Spark" -c wiki --files
./qmdw search "Parquet Iceberg" -c wiki --files
./qmdw search "Kafka Flink Watermark" -c wiki --files
./qmdw search "四步回答框架 实时指标平台" -c wiki --files
```

Expected: each query returns its dedicated topic note and qmd reports no pending vectors.

- [ ] **Step 4: Verify Git cleanliness and scope**

Run:

```bash
git diff --check
git status --short
git submodule status
```

Expected: no whitespace errors, only intended files changed, and the raw submodule remains pinned to `8a6e95c533c65a6b9bdad03949d50c67048d91ed` with a clean worktree.

### Task 5: Deliver through the existing PR

**Files:**
- Modify through GitHub: PR `#5`

- [ ] **Step 1: Review and commit the implementation**

Stage only the six notes, four navigation files and this plan. Review `git diff --cached --stat` and `git diff --cached`, then commit with:

```bash
git commit -m "WOR-23: split big data guide into visual topics"
```

- [ ] **Step 2: Push and update PR description**

Push `agent/codex-home/89238d8e`, then update PR #5 to summarize the topic split, multi-format source review, Mermaid/image/Canvas visualizations and fresh validation evidence.

- [ ] **Step 3: Take one non-blocking PR snapshot**

Run:

```bash
multica issue pull-requests 68e0404b-aff4-4e34-86fa-d66c09c81798 --output json
```

Expected: PR #5 remains open and linked to WOR-23; do not wait for CI.
